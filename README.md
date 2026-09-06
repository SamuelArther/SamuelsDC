# Crescent Dispatch

A shared planning board for one specific trip: Anniston → Washington on the Amtrak
Crescent, Christmas 2026, four people, eight days.

Live at **dc.myway.sambonius.net**.

## What it is

One HTML file. No build step, no dependencies, no server. Open `index.html` and it
works — offline, on a phone, from a USB stick.

The whole trip is modeled as **18 schedulable outings** built out of **25 venues**.
Four of the outings are bundles the board always moves together (the Capitol +
Library of Congress; the WWII → Vietnam → Lincoln → Korea memorial loop; the White
House + National Christmas Tree; Jefferson → FDR → MLK around the Tidal Basin),
because those are single trips in real life and scheduling them apart is a lie.

Each venue carries the facts that actually decide a schedule:

| Attribute | What it decides |
| --- | --- |
| `load` (Easy / Real / Big) | How much of the day's battery it eats |
| `period` (day / night) | Which slot it can occupy at all |
| `min` / `ideal` hours | The shortened visit vs. the full one |
| `resv` | Whether it needs a booking, and how badly |
| `w` (rain/cold/wind/heat fit) | Whether December ruins it |
| `closed` | Federal Sunday closures, holiday closures |
| `bundle` | Which outing it belongs to |

## What it does

**The board.** Eight days, two slots each (daytime / after dark). Drag an outing in,
or tap it and tap a slot. Arrival and departure slots are fixed — the train decides
those. Each day shows a four-pip battery; two Bigs in one day turns it red.

**Ranking.** Every person ranks all 18 outings. Points are Borda — first place is
worth 18, last is worth 1. The tally shows every ballot's position side by side and
highlights the outings the family splits hardest on, because those are dinner
conversations, not scheduling problems. "Plan from the tally" rebuilds the whole
board from the family's order instead of the authored seeds.

**Checks.** Live, and never silent about cost:

- Closure conflicts (the Capitol and the Library of Congress are shut Sundays — and
  both the arrival and departure days of the default trip are Sundays)
- Two Bigs stacked in one day
- Must-see outings stranded on the bench, named
- Bookings still open, with the Monument's 30-day ticket drop called out
- Weather fit against per-day cold / wind / rain switches
- Whether Bart still gets home before he is back on the clock Thursday Dec 10

**Roster.** All 25 venues with their real planning attributes, not marketing copy.

**Logistics.** Both trains, the booking tracker, the house rules, packing.

**Export.** Writes a real `.ics` of the placed week.

## Sharing

The page works standalone with `localStorage`. Published as a Claude Artifact it
picks up the `db` capability and the board goes live — every placement, weather
switch, booking tick and ballot syncs to everyone with the page open, instantly. The
status dot in the header says which mode you are in.

## Roles

Bart is the dispatcher: dates and nights are his. Everyone else can rank, place,
move, book, and cut. The nights slider is the only control that is read-only for the
rest of the family — mirroring how the trip actually works.

## Deploying

It is one static file. Any of these work:

```
# GitHub Pages — Settings → Pages → deploy from branch main, root
# then point dc.myway.sambonius.net at it with a CNAME

# Cloudflare Pages
npx wrangler pages deploy . --project-name samuels-dc
```

For a custom domain on GitHub Pages, add a `CNAME` file containing
`dc.myway.sambonius.net` and set the matching DNS record.
