# M7 natural-walls step — batch record (Drip, Overlook, Span, Stair, Choir)

Per-room loop (spec): lint report + proposed grid → owner rules → apply → re-check content →
validators + tests → capture. Captures: `<room>-<version>-*.png` in this folder.

## Drip chamber (`room_drip`) — round 1 proposal (v3)

**Before (grey-box open box):** 6 `straight_run` (every wall), 0 other; rock 30.6%.

**v3:** a bowl — rim profiled in 2–3 tile steps, two 2×2 stalactites from the ceiling, 2-wide dips
in the floor. **0 wall findings, 0 teeth; rock 30.2%** (0.2 over the band — a warning). Fixed points
all unchanged: N opening cols 14–15, S opening cols 14–15 (the `n_step` gate), chime `[8,10]`,
note 2 `[16,8]`, `from_gallery` / `from_overlook` cells — all on floor, both landings on floor.
**Gate seals:** flood fill with the gate shut → Overlook exit unreachable; open → reachable.
The gate's slab now sits in open floor, not a corridor: it still seals, by geometry alone.

Review points: (1) weak *pit* read — the grid can't show depth, so v3 reads as a hall; (2) the gate
is invisible in grey-box (AbilityGate draws nothing), so the exit reads as an ordinary notch.

```
##############..################
######..###.....##...##...######
###.....##...........##.....####
#.......##...........##.....####
#..............................#
#..............................#
##............................##
##............................##
#..............................#
#..............................#
#..............................#
##...........................###
##...........................###
##..........................####
###.......................######
####...................#########
######...##.......##...#########
##############..################
```

## Drip chamber — round 2 proposal (v4, owner asked for the exit slot)

v3 with the bowl floor funnelled into a 2-wide slot (cols 14–15, rows 14–17), so the `n_step` gate
plugs a corridor and the exit reads as a gap in the floor rather than a notch. East rim pushed out a
tile to win back floor. **0 wall findings, 0 teeth; rock 33.3%** (over the 20–30% band — walling the
slot also cuts floor off either side of the funnel; lower would mean a rim thinner than one tile).
Fixed points unchanged and on floor; gate seals (shut → Overlook exit unreachable; open → reachable).

```
##############..################
######..###.....##...##...######
###.....##...........##.....####
#.......##...........##........#
#..............................#
#..............................#
##............................##
##............................##
#..............................#
#..............................#
#..............................#
##............................##
##............................##
##...........................###
###........###..###.......######
####.....#####..#####..#########
######...#####..################
##############..################
```

**Ruling (owner, 2026-09-25): v4 APPROVED, rock 33.3% accepted** — the exit slot is the reason
(walling the slot costs floor either side of the funnel). Committed; the gate's grey-box look is
still open. Next: the smooth-walls step runs before the rest of this batch (Overlook, Span, Stair,
Choir).

## Overlook (`room_overlook`) — round 1 proposal (v1)

**Before (grey-box open box):** 6 `straight_run` (every wall), 0 other; rock 30.6%.

**v1:** a ledge. The walkway runs from the N mouth to the S mouth down the west two-thirds; the
chasm is a bite out of the east side (rows 5–12, west lip at cols 21–27, meeting the east wall), so
the path skirts its lip and the player looks *across* it at the far wall rather than down into
it. Rims profiled in 2–3 tile notches; the lip steps back in 2–3 row blocks. **0 wall findings,
0 teeth; rock 46.2%** = 37.0% walls + 9.2% chasm (53 cells). Fixed points all unchanged: N opening
cols 14–15, S opening cols 14–15, `from_drip` [14,3], `from_stair` [14,14], chime `[8,12]` — all on
floor; perimeter byte-identical. Polygon checks clean (loops, footprints, pins, seals); narrowest
59 px. No gate in this room.

```
##############..################
##############..################
######...###.......###...#######
###.........................####
##..........................####
##.........................#####
##......................########
###.....................########
###..................###########
##...................###########
##...................###########
##.....................#########
###.......................######
###..........................###
###...........................##
#####...###........##...###...##
##############..################
##############..################
```

Review points:
1. **The grid has no void.** The chasm can only be `#` (or `o`), so in grey-box it draws as rock
   and — the §2.1 problem — it **occludes light**: the Choir's light could not rise through it as
   built. M7 owes the geometry (spec §2.1); how a chasm renders and whether it occludes is a
   renderer question (M8/M9). Needs a ruling: accept `#` now and record it as an M8 item, or
   something else.
2. **Rock 46.2%**, over the 20–30% band. Walls alone are 37.0% (the notched rims); the chasm adds
   9.2%. Drip precedent: 33.3% accepted for its slot.
3. **Top and bottom rims notch at similar columns** (`[6–8] [12–18] [22–24]` vs
   `[5–7] [11–18] [21–23] [27–29]`) — the mouths pin cols 11–18 on both. A rule-6 (echo) check.
4. **Shaft alignment for the Stair.** The Stair sits directly below (same columns; both openings at
   14–15) and the Choir's 96 columns span the whole Overlook, so the chasm's columns (21–29) must
   stay open through the Stair when it's carved. A constraint the Stair inherits.

**Captures (v1):** `overlook-v1-lit`, dark at `[14,3]` `[19,9]` `[8,12]` `[15,14]`, each with a 2×
close-up of the chasm lip (cols 16–29, rows 3–13). The grid was written into the room file for the
run only and restored after. What they show:

- **It reads as a hall, not a ledge.** The floor is wide everywhere (8–20 tiles), so there is no
  walkway along an edge — just a big room with a bite out of its east side.
- **The chasm is indistinguishable from wall** — same rock body, same rim. Review point 1, seen.
- **The rims scallop regularly.** The 2–3 tile notches draw as evenly spaced round bumps, four on
  top and four on the bottom at matching spacing — rule 5/6 sameness, worse in-engine than on the
  grid.
- **The south-east lobe** (rows 13–15, cols 26–29) reads as a bulge with no purpose.

**Ruling (owner, 2026-09-28): v1 rejected — "draw v2 as a ledge"; add a chasm character.** v1's
chasm was shrunk to protect the rock budget, which is why it read as a hall. New grid character
`v` (chasm): rock to collision, walls, light and every wall rule today (the whole pipeline tests
`== "."`), reported apart and outside the rock budget, and marked so M8/M9 can later render depth
and let light through without re-marking rooms. Lint + 5 tests; no Godot change.

## Overlook — round 2 proposal (v2)

**v2:** a real ledge. A 6–11 tile walkway curves down the west wall from the N mouth to the S mouth;
the chasm (`v`) fills the east (cols 10–29), running to the perimeter; a 2-row promontory at rows
8–9 juts 3 tiles into it — the overlook point. Lip steps in 2-row blocks, ≤3 tiles. **0 wall
findings, 0 teeth; rock 38.2% + chasm 40.1%.** Fixed points unchanged and on floor, perimeter
byte-identical, polygon checks clean, narrowest 59 px.

```
##############..################
##############..################
###########.......vvvvvvvvvvvv##
########..........vvvvvvvvvvvv##
#####..........vvvvvvvvvvvvvvv##
#####.......vvvvvvvvvvvvvvvvvv##
###.......vvvvvvvvvvvvvvvvvvvv##
###.......vvvvvvvvvvvvvvvvvvvv##
###..........vvvvvvvvvvvvvvvvv##
##...........vvvvvvvvvvvvvvvvv##
##........vvvvvvvvvvvvvvvvvvvv##
###.......vvvvvvvvvvvvvvvvvvvv##
###.........vvvvvvvvvvvvvvvvvv##
#####.........vvvvvvvvvvvvvvvv##
########.........vvvvvvvvvvvvv##
###########......vvvvvvvvvvvvv##
##############..################
##############..################
```

**Captures (v2):** `overlook-v2-lit`, dark at `[14,3]` `[11,9]` `[8,12]` `[15,14]`, 2× close-ups of
cols 2–19, rows 3–14. Grid written in for the run and restored after.

- **Reads as a ledge.** A C-shaped walkway on the west wall with a dark mass east of it; standing on
  the promontory the player faces across the chasm.
- **The chasm still draws as rock** (expected — `v` is data only until M8/M9).
- **Rock 38.2%** (walls only). The two corner masses left of the mouths are forced: next to a
  centred opening, every row-2 and row-15 floor cell has a wall face, so the rims can only step in
  by ≤3 a row — a triangle of rock each side. Drip precedent 33.3%.
- **Rule 6 watch:** the C is close to mirror-symmetric top to bottom (both bends step out 3, 3, 2).
- **Nubs** at the N and S mouths' east sides (cols 16–17) — the landing needs cols 14–15, and the
  lip can't step back in faster than 3.
- **Stair inheritance:** chasm cols 10–29 — the Stair must keep a shaft open under them.

**Ruling (owner, 2026-09-28): v2 APPROVED as drawn** — rock 38.2% (+ 40.1% chasm), the top/bottom
near-symmetry and the mouth nubs accepted. Applied to `room_overlook.json`. Content re-checked, all
on floor: `from_drip` [14,3], `from_stair` [14,14], chime `door_omega_frag2` [8,12], both links; no
pickups, props or gates. Polygon checks clean (narrowest 59 px); parity fixture regenerated;
`check_all.sh` 16/16. Captures of record: the v2 set above (same grid). Next in the batch: the
Span — its `NoteRegistry` prerequisite first.

## The Span (`room_span`) — round 1 proposal (v1)

**Prerequisite done first (`341cdff`):** internal `ability_gates[].note` is now checked by the
`RoomGraph` boot check and by `lint_rooms` (proved by typo-ing the Span's gate: both fire).

**Before (grey-box open box):** 6 `straight_run`, rock 26.4%. The `n_mend` gate at [40,8] blocked
nothing — the player could walk round it.

**v1:** a crossing. The fissure (`v`, cols 32–48) runs the full height, top rock to bottom rock,
and narrows to cols 37–43 at rows 6 and 10; the collapsed bridge is rows 7–9 across it — exactly
under the gate's 72×90 px slab (cols 39.3–41.7, rows 7–9) and inside its exempt zone, so the lint
leaves it straight. West chamber: Door C (top, cols 15–16) and its chime [20,7]; east chamber: the
arrival from the Choir. Rims and fissure lips are built from 2–3 tile segments by a scratch
generator (segments ≥2 can't make teeth or unit staircases; ≤3 keeps runs under the limit), then
hand-fixed (one tooth, two runs, a pinch in Door C's approach). **0 wall findings, 0 teeth; rock
27.0% — inside the band — + 14.7% chasm.** Fixed points unchanged and on floor; polygon checks
clean; narrowest 59 px. **Gate seal (polygon flood fill from the `from_choir` landing): gate shut →
Door C unreachable; open → reachable.**

```
###############..###############################################
############..#..####..#####..##vvvvvvvvvvvvvvvv##...###########
#..##..#####...........#####....vvvvvvvvvvvvvvvvv#......##..####
#..##..##..............###........vvvvvvvvvvvvvvv#..........####
#.................................vvvvvvvvvvvvv.............####
##................................vvvvvvvvvvvvv..............###
##...................................vvvvvvv.................###
###...........................................................##
###.............................................................
###.............................................................
##...................................vvvvvvv..................##
##................................vvvvvvvvvvvv.................#
##................................vvvvvvvvvvvv.................#
#................................vvvvvvvvvvvvv.................#
#...##....##.........##..........vvvvvvvvvvvvvvvv.........##..##
##..##....##...###...####.......###vvvvvvvvvvvvvv.......####..##
######..###################..####vvvvvvvvvvvvvv####..###########
################################################################
```

**Captures (v1):** `span-v1-full-lit` / `-full-dark` (whole room stitched — two player figures is
the stitch), dark at `[44,8]` `[36,8]` `[20,7]` `[15,4]`, 2× close-ups of cols 28–51.

- **Reads as a crossing** — two chambers joined by one bridge through the fissure's neck.
- **The fissure draws as rock** above and below the bridge (expected; `v` is data only).
- **The gate is invisible** (open item: `AbilityGate` draws nothing) — a stranger meets an unmarked
  wall mid-bridge.
- **The west rims scallop** — the bottom-left especially reads as a row of evenly spaced lobes,
  the same sameness as Overlook v1.
- **The bridge is dead straight** for 7 tiles (the gate zone pins it). Reads as built — arguably
  right for a bridge.

**Ruling (owner, 2026-09-28): reshape the west rims before approval.**

## The Span — round 2 proposal (v2)

**v2:** v1 with the west chamber (cols 0–31) redrawn by hand as low-frequency profiles instead of
generated notches. The v1 lobes came from depth alternating in/out every 2–3 tiles; v2 changes depth
by one per 2–3 tile segment, so walls run as slopes (still no unit steps, still ≤3 per run), and
puts the medium features on alternating walls: top — an alcove up into the border at cols 10–12
and a hanging rock mass sloping to 3 deep at cols 26–28 by the fissure; bottom — an alcove down at
cols 4–6 and a floor mass rising 3 deep at cols 12–19; west wall — one alcove at rows 8–10. East
chamber, fissure and bridge unchanged. **0 wall findings; rock 29.4% (in band) + 14.7% chasm;** gate
seal holds (shut → Door C unreachable from `from_choir`; open → reachable); fixed points on floor;
polygon checks clean; narrowest 59 px.

```
###############..###############################################
##########...##..###############vvvvvvvvvvvvvvvv##...###########
#######..............###########vvvvvvvvvvvvvvvvv#......##..####
####...................#########..vvvvvvvvvvvvvvv#..........####
###.......................###.....vvvvvvvvvvvvv.............####
##................................vvvvvvvvvvvvv..............###
##...................................vvvvvvv.................###
##............................................................##
#...............................................................
#...............................................................
#....................................vvvvvvv..................##
##................................vvvvvvvvvvvv.................#
##................................vvvvvvvvvvvv.................#
##.............###...............vvvvvvvvvvvvv.................#
###.........########.............vvvvvvvvvvvvvvvv.........##..##
####......#############...###...###vvvvvvvvvvvvvv.......####..##
####...##########################vvvvvvvvvvvvvv####..###########
################################################################
```

**Captures (v2):** `span-v2-full-lit` / `-full-dark`, dark at `[20,7]` `[6,12]` `[28,4]`, 2× close-ups
of the west chamber. The west chamber reads as one organic shape — broad rounded west end, the floor
mass rising mid-bottom, the hanging rock at the fissure — with no run of lobes. **The east chamber
still carries v1's generated notches** (two small ones top-right, a lobe bottom-right).

**Ruling (owner, 2026-09-28): v2 APPROVED "for now"** — the east chamber keeps v1's generated
notches for the moment. Applied to `room_span.json`. Content re-checked, all on floor: `from_choir`
[62,8], `from_threshold` [15,4], chime `door_c` [20,7], the `n_mend` gate [40,8], both links. Parity
fixture regenerated; `check_all.sh` 16/16. Captures of record: the v2 set. Open: the gate's
grey-box look; the east chamber's notches.

**Ruling (owner, 2026-09-28): a gap placeholder for ability gates, and a 2-row bridge.** Considered
and not taken: a dedicated bridge room (it wouldn't fix the gate opening on ownership or its
invisibility, would make the crossing a room edge like the Drip's, and changes the 11-room map).

- **Gap placeholder.** `AbilityGate` now draws, while shut, its blocker footprint as a `rock_void`
  gap with three `rock_mid` plank stubs reaching in from each approach side (oriented by `facing`),
  and stops drawing when it opens. Applies to every ability gate — the Drip exit reads as a gap in
  its slot too. Placeholder until M11. Captures: `span-v3-dark-46-8`, `span-v3-dark-34-8`,
  `drip-gap-*`.
- **2-row bridge.** Row 7 across the crossing (cols 37–43) is now chasm; the bridge is rows 8–9,
  the 2-tile width of every opening, still wholly under the slab. 0 wall findings; rock 29.4% +
  15.3% chasm; gate still seals; narrowest 59 px; parity fixture regenerated; `check_all.sh` 16/16.
- **Cosmetic, open:** the gate is centred on cell [40,8] and the bridge is rows 8–9, so the gap box
  pokes a tile above the bridge into the chasm (and one stub sits over chasm). Reads fine as a hole;
  moving the gate to the bridge's centre is a data change left for the owner.

## The Stair (`room_stair`) — round 1 proposal (v1)

**Before (grey-box open box):** 6 `straight_run`, rock 18.5%.

**v1:** a shaft. A `v` band runs edge to edge down the east (the shaft under the Overlook's chasm
columns; rows 0–1 and 52–53 open to the room edges so it continues into both neighbours), and the
descent winds down the west side from the top opening to Door B. Both edges are 2–3 row segments
from a scratch generator with momentum (so bends are long, not alternating), hand-fixed at the
bottom where Door B's approach pinned 4-row runs. Ledges jut into the shaft at rows 18–21, 30–35
and 43–44; the west wall's outcrops stagger against them. **0 wall findings, 0 teeth; rock 32.1% +
36.6% chasm.** Fixed points on floor (`from_overlook` [14,3], `from_choir` [14,49], chime `door_b`
[10,26], both openings); polygon checks clean incl. Door B's seal; narrowest 59 px.

```
##############..##vvvvvvvvvvvv##
##############..##vvvvvvvvvvvv##
###########......vvvvvvvvvvvvv##
###########......vvvvvvvvvvvvv##
###########.......vvvvvvvvvvvv##
########..........vvvvvvvvvvvv##
########.........vvvvvvvvvvvvv##
########.........vvvvvvvvvvvvv##
######..........vvvvvvvvvvvvvv##
######..........vvvvvvvvvvvvvv##
#######.........vvvvvvvvvvvvvv##
#######..........vvvvvvvvvvvvv##
########.........vvvvvvvvvvvvv##
########.........vvvvvvvvvvvvv##
########..........vvvvvvvvvvvv##
######............vvvvvvvvvvvv##
######...........vvvvvvvvvvvvv##
######...........vvvvvvvvvvvvv##
####................vvvvvvvvvv##
####................vvvvvvvvvv##
####..................vvvvvvvv##
###...................vvvvvvvv##
###.................vvvvvvvvvv##
####................vvvvvvvvvv##
####...............vvvvvvvvvvv##
######.............vvvvvvvvvvv##
######.............vvvvvvvvvvv##
######............vvvvvvvvvvvv##
#########.........vvvvvvvvvvvv##
#########.........vvvvvvvvvvvv##
#########..........vvvvvvvvvvv##
#######............vvvvvvvvvvv##
#######............vvvvvvvvvvv##
##########..........vvvvvvvvvv##
##########..........vvvvvvvvvv##
##########..........vvvvvvvvvv##
#########.........vvvvvvvvvvvv##
#########.........vvvvvvvvvvvv##
#########.......vvvvvvvvvvvvvv##
#######.........vvvvvvvvvvvvvv##
#######...........vvvvvvvvvvvv##
######............vvvvvvvvvvvv##
######............vvvvvvvvvvvv##
#######.............vvvvvvvvvv##
#######.............vvvvvvvvvv##
##########..........vvvvvvvvvv##
##########.......vvvvvvvvvvvvv##
##########.......vvvvvvvvvvvvv##
###########.......vvvvvvvvvvvv##
###########.......vvvvvvvvvvvv##
############.......vvvvvvvvvvv##
############.......vvvvvvvvvvv##
##############..##vvvvvvvvvvvv##
##############..##vvvvvvvvvvvv##
```

**Captures (v1):** `stair-v1-full-lit` / `-full-dark` (three screens stitched), dark at `[10,26]`
`[14,5]` `[14,45]`, 2× close-ups of rows 18–33.

- **Reads as a winding cave corridor, not a shaft** — `v` draws as rock, so the drop beside the path
  is invisible (the M8/M9 renderer question again).
- **Ledges are modest** — only rows 18–21 clearly juts; the others read as ordinary bumps.
- **Ledges are one-sided** — the shaft is east, so ledges only jut from the path's side; the
  stagger comes from the west wall. The spec's "staggered ledges" may have meant alternating sides.
- **The east lip bumps more often than the west wall**, though with bigger swings than Overlook v1.
- **The Overlook seam:** the Overlook's rows 16–17 under its chasm are `#`, so the Overlook→Stair
  shaft is cut at the seam. Opening them is a two-row data edit to an approved room — owner's call.
  The Choir also needs its chime under the shaft for the light to line up (a content move).
