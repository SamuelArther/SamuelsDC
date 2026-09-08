# Crescent Dispatch

Samuel's case for Christmas 2026: four people, eight days, and the week that makes it all fit.
Seven options are on the table now — Washington and New York on the Amtrak Crescent,
Wilmington driven or flown, San Jose, Seattle or Portland flown, and Home, which is the
argument for not going anywhere at all. The same board plans all of them.

Live at **dc.sambonius.net**.

## What it is

One HTML file. No build step, no dependencies, no server. Open `index.html` and it
works — offline, on a phone, from a USB stick.

The city strip at the top of the page switches the whole thing between the seven
options. Everything below it — the board, the checks, the ballots, the map, the
export — is the same machinery pointed at a different catalogue. Each city keeps
its own boards, ballots, weather switches and bookings; the dates are shared,
because it is the same eight days wherever we go.

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

Three more live in per-city lookup tables rather than on the venue lines, because
a price is a different kind of fact from a closing day and the lines were long
enough already: `TICKETS` (what it costs to get in), `WORTH` (whether it is worth
it), and `RAILS` (the hops that are a train). See **Money, food and worth** below.

## What it does

**The board.** Eight days, two slots each (daytime / after dark). Drag an outing in,
or tap it and tap a slot. Arrival and departure slots are fixed — the journey decides
those. Each day shows a four-pip battery; two Bigs in one day turns it red.

**Ranking.** Every person ranks all the outings. Points are Borda — first place is
worth the most, last is worth 1. The tally shows every ballot's position side by side
and highlights the outings the family splits hardest on, because those are dinner
conversations, not scheduling problems. "Plan from the tally" rebuilds the whole
board from the family's order instead of the authored seeds.

**Checks.** Live, and never silent about cost:

- Closure conflicts (the Capitol and the Library of Congress are shut Sundays — and
  both the arrival and departure days of the default trip are Sundays)
- Two Bigs stacked in one day
- Must-see outings stranded on the bench, named
- Bookings still open, with the Monument's 30-day ticket drop called out
- Weather fit against per-day cold / wind / rain switches
- What the week costs, and anything on the plan rated thin for the money
- Whether Bart still gets home before he is back on the clock Thursday Dec 10

**Roster.** Every venue in the selected city with its real planning attributes,
not marketing copy — now including the ticket price and the worth verdict.

**Logistics.** Every way in, the booking tracker, the house rules, packing, and
what the week costs once we are there.

**Export.** Writes a real `.ics` of the placed week.

## The seven options

| | Way in | Needs a car | What it is for |
| --- | --- | --- | --- |
| **Washington** | Crescent from Anniston or Atlanta | No | The original ask: memorials in the cold, and nearly everything free |
| **New York** | Crescent from Anniston or Atlanta, or fly | No | The same week aimed at a city that is better after dark |
| **Wilmington** | Drive, or fly to ILM | **Yes** | The battleship, the cape and the Atlantic in December |
| **San Jose** | Fly | No | Christmas in the Park, and San Francisco an hour up Caltrain |
| **Seattle** | Fly | No | The earliest dark of any of them, and a ferry |
| **Portland** | Fly | No | A submarine, a bookshop the size of a block, and ZooLights |
| **Home** | Nothing, or our own car | Only for day trips | Eight days in Douglasville, and two extra days nobody spends travelling |

**Wilmington has no passenger rail at all** — the nearest Amtrak platform is
Charlotte, two hundred miles inland — and nothing in it is walkable from the hotel
except the Riverwalk. It is the one city on the page built on driving rather than on
not driving, and its `artIII` copy says so instead of pretending otherwise.

**The three western cities are flight-only and the page does not invent an
alternative.** Amtrak from Alabama reaches California in three days and eight hours,
by way of New Orleans, and arrives in Los Angeles.

**Portland's headline act is outside our dates.** Peacock Lane does not light until
December 15 and we are home on the 6th. That sits in the cut list with the reason
written out, and the travel check flags it, rather than being quietly left off.

## Boarding the Crescent at Atlanta

Anniston and Atlanta Peachtree are two stops apart on the same train, so for
Washington and New York the way in is now a three-way choice:

| | Anniston | Atlanta | Flying |
| --- | --- | --- | --- |
| Board | Sat 8:04 pm | Sat 11:29 pm | Sun morning |
| Getting there | Walk on | 1 hr 45 drive, then 8 days of parking | Drive to Hartsfield |
| The fare | The longest version | Shorter — a roomette is priced by the mile | Four fares |
| Coming home | Rides all the way back | Into Peachtree 8:43 am, home earlier | Same night |
| The evening | Dinner in the room, Uno south of Atlanta | Beds already down; straight to sleep | — |

Boarding at Peachtree also makes the comparison honest: if we are already pricing
four fares out of Hartsfield, then the train and the plane start from the same city
and the same drive.

## Money, food and worth

**Everybody eats, and it takes hours as well as money.** Lunch comes out of every
daytime slot and dinner out of every evening slot before a single outing is placed,
which is why a day holds less than it looks like it should. Breakfast is at the hotel
before the board starts, so it costs money and no hours. Per-city figures, because
a dinner in Manhattan and a dinner in Wilmington are not the same dinner.

**Admissions are real numbers where they are known and blank where they are not.**
`0` means free and proven free. A missing entry means nobody has priced it yet, and
the page says how many are missing and names them rather than quietly counting them
as nothing. `{flat:n}` is one charge for the whole party, which is how a carload
light show and a car ferry actually work. Figures are published list rates to check
before booking, not quotes.

**`worth` is the honest answer to "is this worth the ticket and the slot".**
Everything is `fair` unless it is named. It is an opinion, which is exactly why it is
written down where it can be argued with instead of being hidden inside whether
something got scheduled. Checks warns when something rated `thin` is on the plan
*and* costs money — the Spy Museum at $35 a head in a city where eleven Smithsonians
are free, the Great Wheel at $18 for fifteen minutes when Kerry Park is free and
higher. It never removes anything; it just says so before the money is spent.

What the seven weeks cost for four people, on the seeded plans (Home shown "In the house") — admissions, all food,
and the rides, with getting there and the hotel deliberately excluded:

| City | Admissions | Food | Rides | Total |
| --- | --- | --- | --- | --- |
| Home (in the house) | $0 | $592 | $0 | **$592** |
| Wilmington | $280 | $1,596 | $70 | **$1,946** |
| Washington | $59 | $1,972 | $275 | **$2,306** |
| Portland | $466 | $1,908 | $334 | **$2,708** |
| San Jose | $416 | $2,192 | $446 | **$3,054** |
| Seattle | $733 | $2,224 | $190 | **$3,147** |
| New York | $701 | $2,412 | $262 | **$3,375** |

Home at $592 for the whole week is not a joke entry — it is eight days of food and
nothing else, against $3,375 for New York. Washington at $59 of admissions is not a
rounding error either — it is the whole argument
for it, and the board can finally show it.

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
drag ever separates the two.

Three more cities use it now: the Fort Fisher ferry to Southport only sails off the
back of the cape day, and Kerry Park is only the walk uphill after Seattle Center.
Washington uses no followers, so the code path is inert there.

### rail

San Jose needed the other one. Every hop on the board is costed as a car at the
city's own speed, which is the honest worst case for a trip across town and the
wrong answer entirely for a fixed rail run — Caltrain takes an hour and ten to San
Francisco whatever the 101 is doing. Priced as forty-two miles of traffic, the board
concluded a San Francisco day could not fit in a day and benched it.

`RAILS` gives a one-way journey time in hours that replaces the road estimate for
any leg touching that venue. Same shape as `follows`: a real-world fact one city
needed, inert everywhere it is not declared. Seattle uses it for the Museum of
Flight and Portland for ZooLights and the Grotto.

### askVersion lives in the shared document

A board sitting on the worker does not know the ask has grown. Each device used
to fold new outings into its own copy, then the next pull handed the stale copy
straight back — so an outing added after a board was last saved would sit on the
bench for ever. The version now rides in the per-city `trip/shared` document, and
whoever loads next repairs the boards once and publishes the result.

Switching the way in redraws the first and last days of the board and moves anything
standing in a slot the journey now eats. Checks names the trade rather than
hiding it, and the choice syncs to the whole family like every other shared
decision on the page.

## Sharing

The page works standalone with `localStorage`. Published as a Claude Artifact it
picks up the `db` capability and the board goes live — every placement, weather
switch, booking tick and ballot syncs to everyone with the page open, instantly. The
status dot in the header says which mode you are in. Share links carry the city
and the way in as well as the plan, so a link opens on the same page you sent it
from.

The worker keeps a separate set of documents per city. Washington's keep the
unprefixed names they have always had, so nothing already saved up there moves;
every other city hangs off its own key as a path prefix (`nyc/`, `wilm/`, `sj/`,
`sea/`, `pdx/`). **The worker needs a redeploy before the five new cities sync** —
until then they save locally and Washington is unaffected.

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

## Home

The seventh tab is the one where we do not go anywhere, and it is built as a real
week rather than as the absence of one. Twenty-five outings: the Christmas movie run,
the tree, baking day, the fire pit, sleeping in on purpose — and then as much of
Georgia as we feel like driving to.

**Home is the only option where the `How` strip changes the catalogue** rather than
the first and last days, because it is not asking how we arrive. There is no
arriving. It is asking how far we are prepared to drive:

| | Reaches | Day / night budget | On the board |
| --- | --- | --- | --- |
| **In the house** | The house and the back garden | 6 h / 4 h | 13 of 25 |
| **Around town** | Everything inside twenty minutes | 7 h / 4 h | 19 of 25 |
| **Day trips** | Atlanta, Pine Mountain, Stone Mountain, Lookout Mountain | 11 h / 7.5 h | 24 of 25 |

Day trips get an eleven-hour day and a seven-and-a-half-hour evening on purpose: a
day out from your own house genuinely is longer than a day from a hotel, because
nobody is checking in, checking out, or moving a bag.

**No journey means no arrival day and no departure day.** Every other option on the
page loses at least one end day to getting there; the Crescent to New York loses
both. Home hands back all eight, which is the strongest single argument it has.

Three new bits of machinery, all inert everywhere else:

- `cuts` on a way in — the unit ids that way puts out of reach. This is what makes
  "In the house" mean something.
- `noJourney` — no arrival or departure day; both end days are fully schedulable.
- `dayHours` / `nightHours` — per-mode budget overrides.

Making `cuts` work turned up a real bug: the comment over `excludedIds()` has always
claimed cut outings are "off the auto-filler for his plan", and they never were —
nothing filtered them, so a cut only ever showed as a flag on a chip. `askableUnits()`
now applies it everywhere Samuel's plan is built. Washington's one cut outing (Air
and Space) had been staying off the board by luck rather than by rule.

Dates and prices verified against the real 2026 calendars: Garden Lights runs Nov 14
2026 – Jan 10 2027, Fantasy In Lights Nov 15 2026 – Jan 3 2027, and Rock City from
mid-November. Stone Mountain has not published its 2026 calendar and runs weekends
and school holidays rather than nightly, so it is modelled as closed Monday to Friday
and can only land on our Saturday or Sunday.

The house coordinates in the file are the neighbourhood, not the door — this page is
served publicly.
