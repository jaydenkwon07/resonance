# M7 smooth-walls step — Hollow pilot record

Spec: "M7 — Smooth walls spec" (owner, 2026-09-25; Drive). Handoff: `HANDOFF.md`. Python half:
`scripts/walls.py`; Godot twin: `scripts/room/wall_trace.gd`, `wall_zones.gd`, `wall_outline.gd`;
renderer `scenes/rooms/room_walls.gd`. Captures: `captures/`.

## Phase 1 build (2026-09-26)

- **Python** (step 1): pipeline + checks, `python3 scripts/test_walls.py` → 28 passed (the 28th
  fails if the parity fixture is stale).
- **Godot twin** (step 2): pure `RefCounted`s beside `RoomGeometry`, no autoloads.
  `godot --headless --script tests/test_wall_outline.gd` → **78 passed**: hash32 and room_seed
  values, and **vertex-for-vertex parity at trace, B and C on six fixture grids (box, outcrop,
  saddle, apron, door, internal gate) and all eleven rooms** against
  `tests/fixtures/wall_loops.json` (written by `scripts/export_wall_loops.py`). Loop build is
  4 ms (Hollow) to 12 ms (Choir) per room entry.
- **Flag:** `godot . -- --walls=smooth` (debug builds; default `bevel`). `--walls-amp=<px>`
  overrides `ROUGH_AMP_MAX` so B is `--walls-amp=0`.
- **Rendering choice:** rock is drawn by painting floor *over* it, not by clipping — no
  `clip_children`, so nothing depends on how canvas groups take the CanvasModulate + PointLight2D
  lighting. Back to front: a rock-body `Polygon2D` over the padded bounds (the atlas's interior
  rock tile, repeated); each loop as a `Polygon2D` by nesting depth — floor outlines textured with
  a baked image of the room's usual per-cell floor tiles (so the floor is pixel-identical to the
  bevel's), outcrops with the rock body; a closed 2 px `Line2D` rim (`RockStyle.seam_px`/
  `seam_tone`) on every loop. Antialiasing off. Collision: one `StaticBody2D`, a
  `ConcavePolygonShape2D` of the loop's closed segments per loop. Occluders: one closed
  `OccluderPolygon2D` per loop. All three from the same `PackedVector2Array`.
- **Bevel untouched:** `--walls=bevel` (default) is today's `TileMapLayer` path.

## Phase 1 report (step 4)

Captures, same shot set as the natural-walls v5 pilot (full-bright, dark at `[4,12]` start,
`[18,12]` before the reveal, `[20,13]`, `[22,12]`, each with a 2× close-up of tiles
`14,4 → 29,17`): `captures/hollow-{bevel,smooth-b,smooth-c}-*.png`.

| | bevel (today) | smooth B | smooth C |
|---|---|---|---|
| Loop vertices | 78 (trace) | 294 | 474 |
| Rock % by area (in bounds) | 72.9 (cells) / 73.0 (trace) | 73.1 | 73.1 |
| Narrowest passage | — | **32 px** | **32 px** |
| Content crossed by wall | — | none | none |
| Pins held / loops valid / seals | — | yes / yes / yes | yes / yes / yes |

- **Narrowest passage 32 px, at the neck between the waking pocket and the crawl.** The player
  box is 30 px, so the margin is 2 px. The spec asks for "player diameter plus a margin" but
  doesn't set the margin — **needs a ruling.** For reference the raw trace (no corner cut) is
  29 px there and would seal the Hollow; corner cutting is what opens it.
- **Pinning oddity: a hard corner where the pinned exit apron meets a cut wall** (east exit,
  visible in every smooth shot at the mouth's two inner corners). Pinned segments are never cut,
  so the smooth wall meets the straight apron at an angle. Accept, or let the first pinned
  vertex beyond the apron be cut — owner's call.
- **Carved rooms get roughened too** (Phase 2 note, measured now): the Antechamber goes 24 → 398
  vertices in C, Resonance 24 → 898. Whether that still reads as built is the Phase 2 capture
  question; not decided here.
- Content: the pickup, entries and the exit zone are clear of wall in B and C.

## Still open for the owner (step 5)

- **B or C**, and any tuning of the six constants (`WallOutline`/`walls.py`, one place each).
- Clearance margin (above).
- The apron-corner kink (above).
- Feel check in-engine: slide along walls, round the low bend, walk the 3-tile channels —
  `godot . -- --room=room_hollow --walls=smooth` (add `--walls-amp=0` for B).
