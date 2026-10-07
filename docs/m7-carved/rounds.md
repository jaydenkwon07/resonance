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

## Rulings (2026-10-06)

Owner answered 1–3; delegated 4–5.

1. **Carved rooms are smoothed less.** `CARVED_CHAIKIN_PASSES = 1` (natural rooms stay at 2), keyed
   on `geometry: "carved"` via `passes_for()` in `walls.py` and its twin `WallOutline`. Roughness is
   unchanged. "Less", not "none", so 1 rather than 0: one pass leaves a short 45° chamfer and keeps
   the niches and columns square. 0 would be the raw cell-centre trace, a one-constant change if the
   chamfers still read soft. Captures: `threshold-v2-full-*`, `antechamber-v2-full-*`.
2. **Rock ~35% is accepted for carved rooms** (Threshold 35.4%, Antechamber 34.0%). It stays a
   lint warning; nothing is baselined for it.
3. **The Antechamber's west transept gets a sealed door** (5 sockets, like the other three sealed
   exits): an opening at W rows 8–9 with `sealed_doors [0,8]`, no link or graph edge. The slab
   overhangs rows 7 and 10 by half a tile, so both side recesses grew to rows 6–11 (mirrored on the
   east) or the wall crosses the door zone. Rock 35.1% → 34.0%. Captures: `antechamber-v2-*`.
4. **Cistern-side stub: accepted for grey-box, no placeholder** (decided by Claude, delegated). A
   sealed door would block the arrival cell `from_threshold [23,34]` (its collision sits on the
   landing), and a non-blocking frame is new presentation code (M10). **Watch item for the stranger
   playthrough:** note whether they try the notch and how long they spend there; that's the M10 input.
5. **Cistern `straight_run (25,33)` baselined** (decided by Claude, delegated): breaking the run
   would be a second edit to locked Cistern geometry, for a wall that reads as built anyway.

## Resonance — round 1 (v1, 2026-10-06) — DRAFT, awaiting ruling

A ring around a central core, mirrored on both axes (cols 31|32, rows 17|18). Four apses open off
the north and south arms. Three are for the boss door's stations, and the fourth is held for the
fifth-note station the layout doc anticipates. The north and south arms narrow to 4 rows between
their apses, giving M12 somewhere to gate one station from the next. The room file is unchanged
until a ruling. Top half shown; rows 18–35 mirror it:

```
 0 ################################################################   N band
 1 ################################################################
 2 ######.............##########################.............######   NW / NE apses, cols 6–18 / 45–57, rows 2–5
 3 ######.............##########################.............######
 4 ######.............##########################.............######
 5 ######.............##########################.............######
 6 ###.........................########.........................###   N arm, rows 6–12; narrowed to rows 9–12 at cols 28–35
 7 ###.........................########.........................###
 8 ###.........................########.........................###
 9 ###..........................................................###
10 ###..........................................................###
11 ###..........................................................###
12 ###..........................................................###
13 ###.............oooooooooooooooooooooooooooooooo.............###   core `o`, cols 16–47, rows 13–22
14 #...............oooooooooooooooooooooooooooooooo...............#   W/E vestibules, rows 14–21
15 #...............oooooooooooooooooooooooooooooooo...............#
16 #...............oooooooooooooooooooooooooooooooo...............#
17 ................oooooooooooooooooooooooooooooooo................   W: from the Antechamber · E: sealed Act 2 door [63,17] (both unchanged)
```

Checks (`check_room.py --grid … --narrowest`): lint, loops, footprints, pins, seals clean; narrowest
59 px. Rock **31.1%** excl outcrops / 45.0% with the core. Entry `from_antechamber [1,17]` and the
sealed door unchanged. The vestibules must reach rows 14–21: shorter ones let the wall cross the
sealed door's zone (rule in `.claude/rules/rooms.md`). Earlier scratch drafts merged the apses into
the ring corners, so they didn't read as separate places, and ran 37–39% rock.

Captures: `resonance-v1-full-lit.png`, `-full-dark.png`, `-dark-2-17` (arrival), `-dark-31-10`
(the N narrowing), `-lit`, close-ups of the north narrowing. The four player figures on the full
captures are the capture tool's camera stops, not content.

For the owner:
1. **Where is the boss door?** The layout doc calls the room "the boss door". The only door here is
   the east edge's 5-socket sealed Act 2 exit, and doors are only placeable on edges today. Is the
   boss door that east door (opened by the station melody, leading to Act 2), or something at the
   core? A core door would need its own face carved into the core, so this can change the grid.
2. **Station gating is M12, and can't be today's `AbilityGate`.** That gate lifts when the note is
   *held*, and the player arrives holding all three, so every gate would already be open. The
   narrowings are only the seam. Which apse is which station is the melody order: yours, and not
   needed until content finalisation.
3. **Ring width.** The W/E arms are 13 tiles wide and N/S 7. Generous for a 2×2 room; at one screen
   the player sees part of the ring at a time. Narrow the arms (more core, more rock), or keep?
4. The core is outcrop `o`, so it sits outside the rock budget. As `#` it would read 45%.

### Owner ruling on round 1 (2026-10-06): the boss door is in the core

The owner's direction, in their words: *"I want there to be an actual fight. … I want option B. But I
want that entire room … to be some kind of large puzzle needed to open the door in the center. Once
the puzzle (or even some kind of mini fight like an arena in hollow knight) is completed, then we
will be able to go in the door and actually fight the boss. The boss itself will be for later (much
later) and the puzzle/arena will be right before we implement the boss. Priorities: the boss will be
one of the last priorities along with the pre-boss fight/puzzle."*

- **Option B:** the boss door sits in the core's face; the east edge stays the sealed Act 2 exit.
- **A boss fight exists** (answers CLAUDE.md §8 "does combat exist at all", for the boss at least).
  Its approach is still open.
- **The ring is the pre-boss challenge:** a room-wide puzzle or an arena fight that opens the core
  door. Which one is open. §3.9's station melody may or may not be it.
- **Both are last priorities**: the pre-boss puzzle/arena lands just before the boss.
- **This disagrees with the design doc** (§3.9: the stations' melody *is* the boss, and the demo
  ends when the door opens). The design doc is the owner's to update (Drive).

## Resonance — round 2 (v2, 2026-10-06) — DRAFT, awaiting ruling

Round 1 plus the core's west face: a 2-deep, 4-tall recess (cols 16–17, rows 16–19) where the door
will stand, facing the entry so it's the first thing seen. Rows 13–24:

```
13 ###.............oooooooooooooooooooooooooooooooo.............###
14 #...............oooooooooooooooooooooooooooooooo...............#
15 #...............oooooooooooooooooooooooooooooooo...............#
16 #.................oooooooooooooooooooooooooooooo...............#
17 ..................oooooooooooooooooooooooooooooo................
18 ..................oooooooooooooooooooooooooooooo................
19 #.................oooooooooooooooooooooooooooooo...............#
20 #...............oooooooooooooooooooooooooooooooo...............#
21 #...............oooooooooooooooooooooooooooooooo...............#
22 ###.............oooooooooooooooooooooooooooooooo.............###
23 ###..........................................................###
24 ###..........................................................###
```

Checks clean; narrowest 59 px; rock 31.1% excl outcrops. Captures: `resonance-v2-full-lit.png`,
`-full-dark.png`, `-dark-12-17` (approaching the face), `-lit`, close-ups of the face.

For the owner:
1. **The recess is empty in grey-box.** Doors can only be placed on room edges today, so no door can
   stand in the face yet. For the stranger playthrough, a blank notch in the core may not read as
   "the door". Option: let `sealed_doors` take an interior cell plus a `facing`, as `ability_gates`
   already do. That's a small code change, and it would show a shut door there until the real one.
2. **The apses and narrowings were shaped for §3.9's stations.** They stay as flexible geometry
   until the puzzle/arena is designed; an arena might want the ring more open.
3. **M7's "three station markers"** (content finalisation) assumed §3.9. Drop them from M7, or keep
   placeholders?
4. **Where the demo ends:** at the core door opening, or after the boss? The boss is much later, so
   the Act 1 demo (M14) may need to end earlier.

### Owner rulings on round 2 (2026-10-06)

1. **Shut door in the core face: yes.** `sealed_doors` now takes an optional `facing`. Without one
   a door faces in from its edge, as before. With one it stands at an interior cell
   (`door_facing` in `roomlib`/`RoomGeometry`; lint, wall pins and placement all use it).
2. **Station markers are dropped from M7.**
3. **The boss fight is the end of the demo**, built last (owner: "Much later, I meant like the end
   of the demo"). The demo no longer ends when a door opens.

## Resonance — round 3 (v3, 2026-10-06) — DRAFT, awaiting ruling

Round 1 plus the core's west face with a shut door: `sealed_doors {at [18,17], facing [-1,0],
sockets 0}`. Zero sockets on purpose: design doc §3.8, "a door with no gems facing you is a door that
is not asking you for anything"; this one opens by the puzzle/arena, not a melody. Rows 14–21,
cols 0–29:

```
14 #...............oooooooooooooo
15 #.................oooooooooooo
16 #.................oooooooooooo
17 .....................ooooooooo
18 .....................ooooooooo
19 #.................oooooooooooo
20 #.................oooooooooooo
21 #...............oooooooooooooo
```

The recess is shaped like an edge door's surroundings, because the wall trace cuts a corner into any
floor cell boxed in on two sides, and the door's slab covers floor. So: the ring side 6 rows tall
(rows 15–20, cols 16–17), the 2-tile opening flanked by rock (col 18), and a 2-tile stub behind it
(cols 19–20) standing in for the corridor an edge door gets off-camera. It reads as the way into
the boss room. Round 2's 4-tall recess and a 3-deep one both failed the footprint check.

Checks clean; narrowest 59 px; rock 31.1% excl outcrops. Captures: `resonance-v3-full-lit.png`,
`-full-dark.png`, `-dark-11-17` (approach), `-lit`, close-ups.
