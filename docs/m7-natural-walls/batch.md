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
