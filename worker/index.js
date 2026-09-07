/*
 * Crescent Dispatch — shared state.
 *
 * A Cloudflare Worker in front of one KV namespace. Four people, one trip,
 * a handful of small JSON documents. No accounts, no login: the URL is the
 * secret, exactly like the share links this replaces.
 *
 * Documents:
 *   boards/family  boards/bart  boards/jess  boards/sam  boards/nanny
 *   votes/bart     votes/jess   votes/sam    votes/nanny
 *   trip/shared
 *
 * GET  /doc/<path>          -> { version, at, by, data }   (404-safe: version 0)
 * GET  /all                 -> { docs: { path: {version, at, by, data} } }
 * PUT  /doc/<path>          -> { version, at, by, data }
 *        body { data, version, by }
 *        `version` is the version this write is based on. If the stored
 *        version has moved on, the write is refused with 409 and the
 *        current document is returned so the caller can merge — the same
 *        contract the artifact runtime uses, and the reason two people
 *        editing at once cannot silently clobber each other.
 *        Pass version -1 to force.
 */

const DOCS = /^(boards\/(family|bart|jess|sam|nanny)|votes\/(bart|jess|sam|nanny)|trip\/shared)$/;
const MAX_BYTES = 128 * 1024;

const CORS = {
  "access-control-allow-origin": "*",
  "access-control-allow-methods": "GET,PUT,OPTIONS",
  "access-control-allow-headers": "content-type",
  "access-control-max-age": "86400",
};

function json(body, status = 200, extra = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store", ...CORS, ...extra },
  });
}

async function readDoc(env, path) {
  const raw = await env.TRIP.get("doc:" + path);
  if (!raw) return { version: 0, at: 0, by: null, data: null };
  try {
    return JSON.parse(raw);
  } catch {
    return { version: 0, at: 0, by: null, data: null };
  }
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: CORS });

    const url = new URL(request.url);
    const path = url.pathname.replace(/^\/+|\/+$/g, "");

    if (path === "" || path === "health") {
      return json({ ok: true, service: "crescent-dispatch", docs: 10 });
    }

    if (path === "all" && request.method === "GET") {
      const names = [
        "boards/family", "boards/bart", "boards/jess", "boards/sam", "boards/nanny",
        "votes/bart", "votes/jess", "votes/sam", "votes/nanny",
        "trip/shared",
      ];
      const entries = await Promise.all(names.map(async (n) => [n, await readDoc(env, n)]));
      return json({ docs: Object.fromEntries(entries) });
    }

    if (!path.startsWith("doc/")) return json({ error: "not_found" }, 404);
    const name = path.slice(4);
    if (!DOCS.test(name)) return json({ error: "bad_document", name }, 400);

    if (request.method === "GET") return json(await readDoc(env, name));

    if (request.method === "PUT") {
      let body;
      try {
        body = await request.json();
      } catch {
        return json({ error: "bad_json" }, 400);
      }
      if (!body || typeof body !== "object" || typeof body.data !== "object" || body.data === null) {
        return json({ error: "data_must_be_an_object" }, 400);
      }

      const serialized = JSON.stringify(body.data);
      if (serialized.length > MAX_BYTES) return json({ error: "too_large", bytes: serialized.length }, 413);

      const current = await readDoc(env, name);
      const base = Number(body.version);
      if (base !== -1 && Number.isFinite(base) && base !== current.version) {
        // Somebody else wrote first. Hand back what is there so the caller merges.
        return json({ error: "conflict", ...current }, 409);
      }

      const next = {
        version: current.version + 1,
        at: Date.now(),
        by: typeof body.by === "string" ? body.by.slice(0, 24) : null,
        data: body.data,
      };
      await env.TRIP.put("doc:" + name, JSON.stringify(next));
      return json(next);
    }

    return json({ error: "method_not_allowed" }, 405);
  },
};
