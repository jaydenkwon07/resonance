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

## Round 1 — owner rulings (2026-09-26)

- **C — chosen.** Start values for all six constants, untuned for now.
- **Exits needn't be a fixed, narrow path; they can vary in length** ("probably better for a more
  natural look"). Applied in the pipeline: an exit pins only its **mouth** — the edge cell and the
  landing cell (`MOUTH_DEPTH` 2), across the opening's two floor cells *and the wall cell flanking
  each side* — instead of the whole 6-cell corridor slot. Past the mouth the exit's walls are
  corner-cut and roughened like any other wall, which also removes the apron-corner kink. Door,
  `requires`-gate and sealed-door zones stay fully pinned (the leaf and its approach need them).
  The flanks matter: without them a wall roughened 1 px into rock beside the mouth fell outside
  the zone and nicked the Gallery's `from_a` landing cell.
- Recapture: `captures/hollow-smooth-c-r1-*.png`. Hollow C now **526 vertices**, narrowest still
  **32 px** at the neck; no content crossed, pins held, loops valid.
- **Seals on polygons now checked in all eleven rooms — all hold.** The polygon flood fill used to
  start from the first *authored* entry cell, which can sit flush against a straight wall (the
  Gallery's did, so its check always failed — before this round too); it now starts from the
  derived landing, where the game puts the player.

## Still open for the owner

- **Clearance margin** — narrowest is 32 px vs the 30 px player; the spec's margin is unset.
- **Exit length in the grid.** The pipeline change frees the *rendered* exit; the grids still
  carry 4–6-tile straight corridors because the natural-walls lint wants a straight
  `APRON_MIN` (4) apron and exempts the corridor slot from rules 1–3. Letting exit length vary in
  the grid too means relaxing that rule — a lint-rule change the spec keeps out of this step, so
  it waits for a ruling (it would land with the natural-walls batch).
- Feel check in-engine: slide along walls, round the low bend, walk the 3-tile channels —
  `godot . -- --room=room_hollow --walls=smooth`.
