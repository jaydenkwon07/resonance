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
