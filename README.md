# Crescent Dispatch

Samuel's case for Christmas 2026: four people, eight days, and the week that makes it all fit. Two cities are
on the table — Washington on the Amtrak Crescent, or New York, either by train or flown — and the same board
plans both.

Live at **dc.sambonius.net**.

## What it is

One HTML file. No build step, no dependencies, no server. Open `index.html` and it
works — offline, on a phone, from a USB stick.

The city strip at the top of the page switches the whole thing between the two
trips. Everything below it — the board, the checks, the ballots, the map, the
export — is the same machinery pointed at a different catalogue. Each city keeps
its own boards, ballots, weather switches and bookings; the dates are shared,
because it is the same eight days either way.

Washington is modeled as **23 schedulable outings** built out of **30 venues**.
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

**Roster.** Every venue in the selected city with its real planning attributes,
not marketing copy.

**Logistics.** Both trains, the booking tracker, the house rules, packing.

**Export.** Writes a real `.ics` of the placed week.

## New York

The second tab: eighteen venues, sixteen outings, on the same eight days. Eleven
things to see plus the same four game nights, and the list leans after dark on
purpose, because that is when most of it is worth looking at.

Two of the outings are bundles the board always moves together. **Ground Zero
after dark** is the memorial and One World Observatory — the same plaza, the
pools lit with the names lit from underneath, then a hundred and two floors up
the tower standing over them. **Christmas in Midtown** is the tree and the Fifth
Avenue windows on one walk. The 9/11 museum is deliberately *not* bundled with
the memorial the way it would be in summer: it shuts hours before the lights come
on, so it is its own daytime trip.

The two observatories are modelled differently on purpose. The Empire State's
86th floor is open to the weather and rates poorly for wind and rain; One World
is entirely behind glass and rates as indoor. On a wet night the board can tell
you which one still works.

### follows

New York needed one new attribute. Walking back over the Brooklyn Bridge is not
a trip of its own — it is the way home from DUMBO — so `follows: "dumbo"` means
the scheduler will only place it in the slot its anchor is already sitting in,
places it after everything else, and Checks calls it out as blocking if a hand
drag ever separates the two. Washington uses no followers, so the code path is
inert there.

**How we get there is undecided, so the page treats it as a variable.** The
`How` control beside the city strip switches between:

| | The train | Flying |
| --- | --- | --- |
| The way in | Crescent 20 all the way to Penn Station | Atlanta to LaGuardia |
| Costs | Two roomettes, and a longer Crescent than Washington | Four round-trip fares out of Atlanta |
| Arrives | A little before 7 pm, so the first evening is gone | Around lunchtime |
| Leaves | Just after 2 pm, so the last day is gone | That evening |
| The week | Six usable days | Eight |

All fifteen asks fit either way — the difference is the slack, not the list.

Neither way is free and the page does not pretend otherwise: New York is four
hours past Washington on the same train, so the sleeper fare goes up with the
distance. Which of the two actually costs less is a question of real fares on
real dates, and nothing here guesses at it.

### askVersion lives in the shared document

A board sitting on the worker does not know the ask has grown. Each device used
to fold new outings into its own copy, then the next pull handed the stale copy
straight back — so an outing added after a board was last saved would sit on the
bench for ever. The version now rides in the per-city `trip/shared` document, and
whoever loads next repairs the boards once and publishes the result.

Switching redraws the first and last days of the board and moves anything
standing in a slot the journey now eats. Checks names the trade rather than
hiding it, and the choice syncs to the whole family like every other shared
decision on the page.

Washington has one way in and so shows no control.

## Sharing

The page works standalone with `localStorage`. Published as a Claude Artifact it
picks up the `db` capability and the board goes live — every placement, weather
switch, booking tick and ballot syncs to everyone with the page open, instantly. The
status dot in the header says which mode you are in. Share links carry the city
and the way in as well as the plan, so a link opens on the same page you sent it
from.

The worker keeps a separate set of documents per city. Washington's keep the
unprefixed names they have always had, so nothing already saved up there moves;
New York's hang off a `nyc/` prefix beside them. **The worker needs a redeploy
before New York syncs** — until then New York saves locally and Washington is
unaffected.

## Roles

Bart is the dispatcher: dates and nights are his. Everyone else can rank, place,
move, book, and cut. The nights slider is the only control that is read-only for the
rest of the family — mirroring how the trip actually works.

## Deploying

It is one static file. Any of these work:

```
# GitHub Pages — Settings → Pages → deploy from branch main, root
# then point dc.sambonius.net at it with a CNAME

# Cloudflare Pages
npx wrangler pages deploy . --project-name samuels-dc
```

For a custom domain on GitHub Pages, add a `CNAME` file containing
`dc.sambonius.net` and set the matching DNS record.
