#!/usr/bin/env bash
# Deploy the Crescent Dispatch sync worker with nothing but curl.
#
# Needs no node and no wrangler. It needs two things from Cloudflare:
#
#   CF_API_TOKEN   an API token with these permissions, account-scoped:
#                    Workers Scripts : Edit
#                    Workers KV Storage : Edit
#                  Create at: Cloudflare dashboard -> My Profile -> API Tokens
#                             -> Create Token -> Create Custom Token
#   CF_ACCOUNT_ID  Cloudflare dashboard -> Workers & Pages -> Account ID
#
# Usage:
#   CF_API_TOKEN=xxx CF_ACCOUNT_ID=yyy ./worker/deploy.sh
#
# Prints the worker URL on success. Put that URL into SYNC_URL in index.html.

set -euo pipefail

: "${CF_API_TOKEN:?set CF_API_TOKEN}"
: "${CF_ACCOUNT_ID:?set CF_ACCOUNT_ID}"

SCRIPT_NAME="${SCRIPT_NAME:-crescent-dispatch}"
KV_TITLE="${KV_TITLE:-crescent-dispatch-trip}"
API="https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID"
AUTH=(-H "Authorization: Bearer $CF_API_TOKEN")
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

say() { printf '  %s\n' "$*"; }
ok()  { python -c 'import sys,json;d=json.load(sys.stdin);sys.exit(0 if d.get("success") else 1)' 2>/dev/null; }

say "1/4  finding or creating the KV namespace"
NS_JSON="$(curl -sS "${AUTH[@]}" "$API/storage/kv/namespaces?per_page=100")"
NS_ID="$(printf '%s' "$NS_JSON" | grep -o "\"id\":\"[a-f0-9]\{32\}\",\"title\":\"$KV_TITLE\"" | head -1 | cut -d'"' -f4 || true)"

if [ -z "$NS_ID" ]; then
  CREATE="$(curl -sS "${AUTH[@]}" -H "content-type: application/json" \
    -X POST "$API/storage/kv/namespaces" --data "{\"title\":\"$KV_TITLE\"}")"
  NS_ID="$(printf '%s' "$CREATE" | grep -o '"id":"[a-f0-9]\{32\}"' | head -1 | cut -d'"' -f4 || true)"
  [ -n "$NS_ID" ] || { echo "could not create KV namespace:"; echo "$CREATE"; exit 1; }
  say "     created $NS_ID"
else
  say "     reusing $NS_ID"
fi

say "2/4  uploading the worker"
METADATA="{\"main_module\":\"index.js\",\"compatibility_date\":\"2026-01-01\",\"bindings\":[{\"type\":\"kv_namespace\",\"name\":\"TRIP\",\"namespace_id\":\"$NS_ID\"}]}"
UP="$(curl -sS "${AUTH[@]}" -X PUT "$API/workers/scripts/$SCRIPT_NAME" \
  -F "metadata=$METADATA;type=application/json" \
  -F "index.js=@$HERE/index.js;type=application/javascript+module")"
printf '%s' "$UP" | grep -q '"success":true' || { echo "upload failed:"; echo "$UP"; exit 1; }
say "     uploaded $SCRIPT_NAME"

say "3/4  enabling the workers.dev route"
SUB="$(curl -sS "${AUTH[@]}" -X POST "$API/workers/scripts/$SCRIPT_NAME/subdomain" \
  -H "content-type: application/json" --data '{"enabled":true}')"
printf '%s' "$SUB" | grep -q '"success":true' || say "     (subdomain call returned: $SUB)"

SUBDOMAIN="$(curl -sS "${AUTH[@]}" "$API/workers/subdomain" | grep -o '"subdomain":"[^"]*"' | cut -d'"' -f4 || true)"
URL="https://$SCRIPT_NAME.${SUBDOMAIN:-YOUR-SUBDOMAIN}.workers.dev"

say "4/4  checking it answers"
sleep 3
HEALTH="$(curl -sS "$URL/health" || true)"
printf '%s' "$HEALTH" | grep -q '"ok":true' && say "     $URL/health -> ok" || say "     not answering yet (DNS can take a minute): $HEALTH"

echo
echo "Worker URL:  $URL"
echo
echo "Now set this in index.html:"
echo "    var SYNC_URL = \"$URL\";"
