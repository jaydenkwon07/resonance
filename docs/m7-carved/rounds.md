# M7 — carving the archetype rooms (Threshold, Antechamber, Resonance)

Carved rooms are symmetric and axis-aligned; exempt from the natural-wall rules, not from carving
(CLAUDE.md "Now"). Same loop as the natural-walls batch (`docs/m7-smooth-walls/HANDOFF.md`, "Authoring
a room proposal"): draft → `check_room.py --grid` → capture → record here → owner rules → apply.

## Threshold — round 1 (v1, 2026-09-29) — APPLIED (owner: "go", 2026-09-29)

Grid (mirrored about cols 15|16; the room file is unchanged until a ruling):

```
 0 ###############..###############   N: the shortcut's back-opened door (C1 — not linked yet)
 1 ###############..###############
 2 ######....................######   north apse
 3 ######....................######
 4 ###..........................###   hall
 5 #..............................#   niche pair, rows 5–7
 6 #..............................#
 7 #..............................#
 8 ###..........................###   pier (2 rows — 1-row piers render as spikes)
 9 ###..........................###
10 #..............................#   niche pair, rows 10–12
11 #..............................#
12 #..............................#
13 ###..........................###
14 ######....................######   south vestibule
15 ######....................######
16 ###############..###############   S: from the Span through Door C (unchanged, col 15)
17 ###############..###############
```

Checks (`check_room.py --grid`): lint, loops, footprints, pins, seals all clean. Warning: rock
**35.4%** (open box was 31.2%) — the 2-row end bands alone are ~21%, so a shaped one-screen carved
room can't reach 30% without thinning them. Entry `from_span [15,14]` unchanged.

Captures: `threshold-v1-full-lit.png`, `-full-dark.png`, `-dark-15-13` (the landing), `-dark-15-4`
(under the shortcut), each with a close-up.

For the owner:
1. **Straight-walled vs the smoothing.** At `CHAIKIN_PASSES 2` + roughness, the corners round off
   and the niches read as soft lobes — symmetric, but not obviously *built*. This is the Phase 2
   open item ("carved rooms: `CHAIKIN_PASSES` 0/1 keyed on `geometry`?"). A renderer change, so a
   ruling, not something to decide in the grid.
2. **The N opening** is carved but unlinked until C1 adds the Cistern's fifth opening and its
   `from_threshold` entry (handoff: Threshold N col 15 ↔ Cistern S col ~22; the S edge already
   holds the 5-gem stub at col 33). The spec wants the two ends landed together.
3. Rock 35.4% — accept for carved rooms, or thin the end bands?

## C1 — the Cistern's fifth opening, round 1 (2026-09-29) — APPLIED (owner: "go", 2026-09-29)

The one sanctioned edit to frozen Cistern geometry. Drafted alongside Threshold v1 so both faces of
the one-way link land together (spec §6 Step 3a). Nothing is applied; all files were restored.

- **Opening:** S edge, **cols 23–24**, rows 34–35 (4 cells rock → floor). Handoff said "col ~22";
  23–24 puts it on the same axis as Door Ω (N, cols 23–24), clear of the 5-gem stub (cols 33–34)
  and the prop at [22,28].
- **Wiring:** Cistern entry `from_threshold [23,34]`; Threshold link `{at [15,0], to room_a,
  from_threshold}`, no door, no `requires`; `rooms.json` gains the Threshold exit and the Cistern
  entry, and **no** reverse exit (non-reciprocal free edge, spec §3.3).
- **Checks with it applied:** `validate_rooms` and `seal_test` pass — both tolerate the
  non-reciprocal edge (the spec's "must confirm in code"). Loops/footprints/pins clean on every
  room; boot passes. Cistern rock **29.9% → 29.7%**. On apply: update `test_lint_rooms`'s pinned
  29.9% and rerun `export_wall_loops.py` (the only failures, both expected).
- **Captures:** `a-c1-full-lit.png`, `a-c1-full-dark.png`, `a-c1-dark-23-33.png` (arrival),
  `a-c1-lit.png`. Compare with `docs/m5-reference/cistern-final.png`: composition unchanged, the
  only difference is the gap in the south wall left of the 5-gem door.

For the owner:
1. **From the Cistern side it's a bare hole to nowhere** until M10 adds the sealed-frame art. The
   player can walk into the 2-tile stub and stop against off-camera rock. The stranger playthrough
   is an M7 gate, before M10 — a stranger may read it as a path. Accept for grey-box, or give it a
   placeholder (e.g. a doorless `sealed_doors` frame, which would need checking against the
   arrival cell)?
2. Cols 23–24 (on Door Ω's axis) vs the handoff's ~22.
3. The full `check_room.py` wall checks (clearance flood fills) on the Cistern take minutes; not run
   yet — will run on apply.

## Applied (2026-09-29)

Owner said "go" on both drafts as proposed: Threshold v1 and C1 at cols 23–24, wired as above.
Still open (not answered by "go", nothing changed for them): carved-room smoothing passes, the
Cistern-side placeholder for the stub, rock 35.4% in the Threshold (stands as a warning).

- `test_lint_rooms` pin 29.9% → 29.7%; `export_wall_loops.py` rerun; `check_all.sh` 18/18.
- `json.dumps(indent=2)` does **not** round-trip `room_a.json` byte-identically: its `props` are
  hand-compacted (`{ "at": [8, 20] }`). Re-compact after a scripted edit. `rooms.json` is
  hand-formatted too — edit it as text.
- Full `check_room.py`: Threshold OK (narrowest 59 px); Cistern OK, with **one new warning** —
  `straight_run at (25, 33) (4 cells)`, the wall between the new opening and the 5-gem stub. Not
  baselined (the baseline is the owner's): accept, or break the run?

## Antechamber — round 1 (v1, 2026-10-06) — APPLIED (owner: "go", 2026-10-06)

A four-column hall: the waiting room before the boss. Distinct from the Threshold's niches by
using free-standing columns instead of side recesses. Grid (mirrored about cols 15|16, apart from
the E exit; the room file is unchanged until a ruling):

```
 0 ################################   N band
 1 ################################
 2 #####......................#####   apse, cols 5–26
 3 #####......................#####
 4 ##............................##   hall, cols 2–29
 5 ##......oo............oo......##   column pair, rows 5–6 (2×2 `o`, cols 8–9 / 22–23)
 6 ##......oo............oo......##
 7 #..............................#   transept, rows 7–10 (one step wider)
 8 #...............................   E: to the Resonance chamber (unchanged, rows 8–9)
 9 #...............................
10 #..............................#
11 ##......oo............oo......##   column pair, rows 11–12
12 ##......oo............oo......##
13 ##............................##
14 #######..................#######   south vestibule, cols 7–24
15 #######..................#######
16 ###############..###############   S: from the Cistern through Door Ω (unchanged, col 15)
17 ###############..###############
```

Checks (`check_room.py --grid … --narrowest`): lint, loops, footprints, pins, seals all clean;
narrowest passage 59 px. Warning: rock **35.1%** (37.8% with the columns), level with the
Threshold's 35.4%, for the same reason (the 2-row N band alone is 11%). Entries unchanged:
`from_cistern [15,14]`, `from_resonance [28,8]`. Two earlier drafts in scratch were 47% and 40%
rock and were widened before capture.

Captures: `antechamber-v1-full-lit.png`, `-full-dark.png`, `-dark-15-13` (arrival from Door Ω),
`-dark-15-8` (centre), `-dark-28-8` (the E exit), and `-lit`, each with a close-up of the west
column pair.

For the owner:
1. **Columns vs the smoothing.** The 2×2 columns render as rounded squares, which reads as built.
   The outer corners soften like the Threshold's. It's the same open carved-room smoothing ruling;
   it doesn't block this draft.
2. **Symmetry and the E exit.** The exit punches through the east transept only; the west
   transept end is blank wall. Accept, or mirror it with a decorative `sealed_doors` frame on the
   W edge (rows 8–9)? A frame there might read as a second way on to a stranger.
3. **Rock 35.1%:** accept for carved rooms (with the Threshold's ruling), or thin the N band?
4. **The "quiet beat"** (spec §5: it goes dark again on purpose) is lighting, M8. Nothing here
   lights it, so it's dark in grey-box already.

Applied as drafted (2026-10-06). "go" didn't answer items 1–3, so nothing changed for them: the
west wall stays blank, rock 35.1% stands as a warning, and carved-room smoothing is still open.
`export_wall_loops.py` rerun; `check_all.sh` 18/18. No content in the room, so no cells to re-check.
