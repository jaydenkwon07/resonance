# M7 smooth-walls step — Phase 2 record (rollout)

Owner rulings from the Hollow pilot (`hollow-pilot.md`): **C** at start values; exits pinned at
the **mouth** only. Then (2026-09-26):

- **Exit length varies in the grid too.** The straight 4-tile `APRON_MIN` apron is gone from the
  lint: an exit must keep only its **mouth** (`roomlib.MOUTH_DEPTH` 2 — edge cell + landing cell,
  one shared `mouth_cells` for the lint exemption and the wall pinning). The "blocked apron"
  warning is now "blocked mouth"; a long straight corridor past the mouth warns like any other
  straight wall. New findings: Gallery `straight_run [2,14]` (its west exit — locked room,
  **added to the baseline**) and **Hollow `straight_run [26,8]`** (its east exit pipe — left as
  an open warning; shortening it is a grid edit on a signed-off room, owner's call).
- **Clearance margin — fine as is** (Hollow 32 px vs the 30 px player). Revisit if the player
  model changes; layouts can change then.
- **Feel — good.** Go Phase 2.

## Step 1 — default switched

`RoomWalls.DEFAULT_STYLE = "smooth"`. `--walls=bevel` still shows the old path (debug builds).

## Step 2 — every check on every room (C)

The polygon flood fill now starts from **every landing** (each `from_*` entry at its derived
landing, `spawn` at its cell) — a fill from one landing can skip a room's narrowest point.

| Room | Geometry | Loops | Vertices | Rock % cells / area | Narrowest | Footprints | Pins | Loops | Seals |
|---|---|---|---|---|---|---|---|---|---|
| Cistern `room_a` | natural | 5 | 926 | 31.9 / 32.0 | 57 | ok | ok | ok | ok |
| Antechamber | carved | 1 | 392 | 30.6 / 30.9 | 59 | ok | ok | ok | ok |
| Gallery `room_b` | natural | 6 | 1333 | 32.6 / 32.7 | 57 | ok | ok | ok | ok |
| Choir | natural | 1 | 1204 | 14.5 / 14.6 | 59 | ok | ok | ok | ok |
| Drip | natural | 1 | 456 | 33.3 / 33.5 | 59 | ok | ok | ok | ok |
| Hollow | natural | 1 | 526 | 72.9 / 73.0 | **32** | ok | ok | ok | ok |
| Overlook | natural | 1 | 394 | 30.6 / 30.9 | 59 | ok | ok | ok | ok |
| Resonance | carved | 1 | 894 | 16.3 / 16.6 | 59 | ok | ok | ok | ok |
| Span | natural | 1 | 712 | 26.4 / 26.8 | 59 | ok | ok | ok | ok |
| Stair | natural | 1 | 756 | 18.5 / 18.8 | 59 | ok | ok | ok | ok |
| Threshold | carved | 1 | 401 | 31.2 / 31.8 | 59 | ok | ok | ok | ok |

Plus: `validate_rooms` "11 rooms reachable, 4 door(s) solvable, ramp holds", `seal_test`,
`lint_rooms` (no errors), 182 Godot tests (parity on all eleven rooms), 34 lint / 28 walls
Python tests, import and 90-frame boot clean in both styles, one-rule grep clean.

## Step 3 — every room captured

`phase2/<room>-{smooth,bevel}-full-{lit,dark}.png` — whole-room composites stitched from one
screen per camera stop (player at each stop's centre, as the M6 Gallery still was made), both
styles, so every room has a same-framing before/after.

**Carved rooms (report, not decided):** Threshold, Antechamber and Resonance keep their straight
walls — two Chaikin passes only round the corners (a ~half-tile radius) and the roughness reads as
a faint 1–2 px wobble along the long edges. They read as rough-hewn cut stone rather than natural
cave. If they should look machined, the options are `CHAIKIN_PASSES` 0/1 and/or `ROUGH_AMP_MAX` 0
keyed on `geometry: carved`.

## Step 4 — locked rooms, for owner re-approval

- **Cistern:** `phase2/a-smooth-full-{lit,dark}.png` beside `a-bevel-*` and
  `docs/m5-reference/cistern-final.png`. The reference predates M7's door rewiring, so it can't
  be matched shot-for-shot; the bevel composite is the same-layout comparison. Openings, entries,
  content and door zones unchanged (pins held, footprints clear). The outcrops now read as
  rounded boulders; the doors' straight jambs stay straight.
- **Gallery:** `phase2/b-smooth-full-{lit,dark}.png` beside `b-bevel-*` and
  `docs/m6-reference/gallery-{final,lit}.png` (same three-screen framing).

## Owner rulings (2026-09-26)

- **Cistern and Gallery — re-approved** against their original references.
- **Carved rooms — keep as captured** (two passes + roughness, like the natural rooms).
- **Retire the bevel — yes, now** (not held until M8).
- Hollow east exit pipe (`straight_run [26,8]`) — not ruled; stays an open lint warning for the
  natural-walls batch.

## Step 5 — bevel retired

- Removed: `scripts/rock/rock_bevel.gd` (`RockBevel`), `scenes/rooms/rock_tileset.gd`
  (`RockTileSet`: the 47-tile blob terrain, per-tile collision polygons and occluders, per-tile
  seam), the `TileMapLayer` path in `room.gd`, the `--walls=` flag and `--walls-amp=`,
  `RockStyle.bevel_convex`/`bevel_concave`.
- Added: `scenes/rooms/rock_atlas.gd` (`RockAtlas`) — only the art the walls use: the five floor
  tiles and the rock body, drawn from the same seeds. `room.gd`'s tile size is now
  `WallTrace.TILE`. **Verified pixel-identical:** whole-room lit and dark composites of the
  Cistern before and after the retirement match byte for byte; the Hollow's differ only in the
  132 px of the spinning note pickup (animation timing).
- Tests: `tests/test_rock_bevel.gd` (23) replaced by `tests/test_wall_shape.gd` (23), concern
  for concern — corners cut at 45° with half-tile legs, straight walls stay straight (was the
  cut region); passes deepen the cut, zero passes is the trace (leg scales the cut); mirror-
  symmetric corners (four corners alike); convex and concave corners both cut, floor on the
  right (active selection, rock-side sign); a one-cell outcrop is its own solid loop even after
  C, all-rock has no wall (lone-outcrop/interior cases); collision segments are exactly the
  drawn edges, whole pixels, in room coordinates (collision polygon matches the silhouette,
  frame). Godot total stays **182**.
