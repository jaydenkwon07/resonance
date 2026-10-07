# M7 handoff — smooth walls (done), then the natural-walls batch

**Written 2026-09-25 for a fresh session.** Read CLAUDE.md first (it wins on code conventions),
then this. Everything here is current as of the last commit named below; verify with `git log`.

---

## Where M7 stands

M7 is the grey-box map (CLAUDE.md "Now" and "Milestone ladder"). Its spine is built: eleven rooms, connected, gated,
validated. Since then, in order:

1. **Room edges rewired to the Act 1 layout map** (`a3df734`): every transition now exits and
   lands on opposite edges, in the direction the layout PDF places the rooms. Carved rooms
   (Threshold, Antechamber, Resonance) have centred openings.
2. **Debug jump-to-room flag** (`783800a`): `godot . -- --room=<id> [--spawn=<entry>]`.
3. **Natural-walls step** (`8d4236e`, `b801e50`, `ebfbd30`) — reshape the natural rooms' grids so
   walls read as cave. Tooling done; **Hollow and Drip done; Overlook, Span, Stair, Choir remain.**
   Records: `docs/m7-natural-walls/hollow-pilot.md`, `docs/m7-natural-walls/batch.md`.
4. **Smooth-walls step — IN PROGRESS** (this doc). The owner paused the natural-walls batch to do
   this first ("now, batch after"): the grid rules made the Hollow clean but it still looks rigid
   and pointy, because the 45° bevel only draws 0°/45°/90° and turns every meeting of two cuts into
   a spike. Fix the renderer, not the grid.

**Git state (updated 2026-09-26):** Phase 1 steps 1–4 are committed on `main` (not pushed — the
owner asks for pushes explicitly). `_capture_room.gd` / `.tscn` / `.gd.uid` in the project root
stay untracked throwaway scaffolding (now takes `--out=`). **Never commit it.** Kept past the
natural-walls batch for the carved rooms' captures (owner, 2026-09-29); **deleted 2026-10-06** when
the carving ended. Recreate a throwaway scene from the routine below if stills are needed again.

**Commit convention:** no `Co-Authored-By` trailer (parent `~/Code/Projects/CLAUDE.md`). Past
commits end with a `Claude-Session:` line only.

---

## The specs (owner's; PDFs outside the repo)

- **Smooth walls:** `~/Downloads/M7 — Smooth walls spec.pdf` (also Drive → Game Design Logs).
- **Natural walls:** `~/Downloads/M7 — Natural walls spec.pdf`.
- **Hollow layout:** `~/Downloads/Resonance — The Hollow (room 1) layout.pdf`.
- **Act 1 layout (all rooms):** `~/Downloads/Resonance — Act 1 room layout-1.pdf`.

Read the smooth-walls PDF before coding — this doc summarises it but isn't a substitute.

### Smooth-walls spec in one screen

Replace the 45° rock bevel with a smoothed, slightly rough outline built from the same grid. One
polygon per wall loop is used for **drawing, collision and light occluders** (honest edges: what
looks solid is solid). No grid, content, link, door, gate or graph changes.

Pipeline, five deterministic stages: **trace** (marching squares at cell centres) → **pin**
(vertices in exit aprons/corridor slots, edge bands, door footprints + approach, gate zones never
move; a segment pinned at both ends is never cut) → **corner-cut** (Chaikin) → **roughen** (hash
offset along the normal, amplitude wandering along the wall) → **snap** (whole native pixels).
Constants, start values: `CHAIKIN_PASSES 2`, `CHAIKIN_RATIO 0.25`, `ROUGH_STEP 6px`,
`ROUGH_AMP_MIN 0`, `ROUGH_AMP_MAX 2px`, `ROUGH_SPAN 120px`. Option **B** = `ROUGH_AMP_MAX 0`;
option **C** = start values.

**Phase 1 — prototype on the Hollow:** (1) Python pipeline + tests + a still — **DONE**;
(2) Godot twin beside `RoomGeometry`, behind a `wall_style` flag, parity test passing on the
Hollow — **DONE** (parity on all eleven rooms); (3) captures in three versions — `bevel`,
`smooth` B, `smooth` C — **DONE**; (4) report — **DONE, in `hollow-pilot.md`**;
(5) owner picks B or C — **DONE: C, exits pinned at the mouth only (round 1, `hollow-pilot.md`)** — and tunes the
constants; record rulings/rounds in `docs/m7-smooth-walls/hollow-pilot.md`. While playing: check
the feel — sliding along walls, rounding the low bend, the 3-tile channels.

**Phase 2 — roll out:** default → `smooth`; run every check on every room; capture every room
(full-bright + one dark); report whether carved rooms still look built (maybe `CHAIKIN_PASSES` 0/1
keyed on `geometry` — report, don't decide); recapture Cistern beside
`docs/m5-reference/cistern-final.png` and Gallery beside its M6 reference for owner re-approval;
**retire the bevel only after owner sign-off** (remove code path + flag, replace the 23 rock-bevel
tests with no coverage loss); update CLAUDE.md's honest-edges line (trim before adding).
**Phase 2 DONE (2026-09-26) — the smooth-walls step is complete; see `phase2.md`.** Owner
re-approved the Cistern and Gallery, kept carved rooms as captured, and the bevel is retired
(`RockBevel`, `RockTileSet`, the `--walls` flag and the 23 rock-bevel tests are gone; `RockAtlas`
+ `tests/test_wall_shape.gd` replace them). The exit apron rule was replaced by the exit mouth
(`roomlib.MOUTH_DEPTH`). **Next: the natural-walls batch (below).**

**Out of scope (stop and report instead):** grid edits (even to fix a clearance/footprint problem
the checks find), moving content, light tuning (M8), surface detail (M9), floor rendering / the
procedural atlas, changing the grid lint rules, sub-tile authoring.

### Owner rulings already made (smooth walls)

- **Start shape = the cell-centre trace** (spec's letter), even though it is NOT exactly today's
  bevel: the trace cuts half-cell legs on both convex and concave corners, while today's
  `RockStyle` has `bevel_convex = 1.0`, `bevel_concave = 0.0`. The `bevel` capture stays today's
  real renderer for the comparison.
- **Flag = a command-line option** `--walls=smooth` (like `--room=`); default `bevel` until Phase 2.
  Not the backtick (that toggles full-bright lighting), not a new key.
- **Placement:** smooth walls now, the natural-walls batch after.
- Still open from the spec (ask when relevant): lean B or C; carved-room passes; the Cistern
  re-approval bar (full store-page gate vs side-by-side); keep the bevel flag until after M8?

---

## Phase 1 step 1 — what exists (Python)

`scripts/walls.py` (pure, stdlib; imports `roomlib` for zones) and `scripts/test_walls.py`
(`python3 scripts/test_walls.py` → **27 passed**). Preview:
`docs/m7-smooth-walls/hollow-loops-python.png` (trace / B / C stacked).

Key functions: `trace(grid)`, `pinned_cells(data)`, `is_pinned(p, zone)`, `chaikin(...)`,
`roughen(...)`, `snap(...)`, `wall_loops(data, passes=, amp_max=)` (the whole pipeline),
`hash32(*ints)`, `room_seed(room_id)`. Checks on the final polygons: `loop_problems` (closed,
simple, no loops touching), `footprint_problems` (content/entry/door-zone floor cells fully in
floor), `pin_problems`, `seal_problems` (seal_test on polygons), `narrowest` (widest square player
that still reaches every exit), `reach` (the flood fill both use), `inside` (even-odd).

**Parity contract — the GDScript twin must match these exactly:**
- Trace: dual grid over cell centres, cells `(-2 .. w)` × `(-2 .. h)`. Out of bounds is rock
  **except** one cell straight out from a perimeter floor cell (an opening's corridor continues
  past the bounds so the mouth isn't narrowed; the loop closes off-camera). Saddles keep **rock**
  connected. Segments oriented with floor on the right in screen space (y down); outer floor loops
  have **negative** shoelace area, outcrop loops positive. Merge collinear vertices, rotate each
  loop to its smallest `(y, x)` vertex, sort loops by that vertex.
- Pins (round 1): each exit's mouth — cells `at + along·m + inward·k`, `m ∈ −1..2` (opening +
  flanking walls), `k < MOUTH_DEPTH` (2) — plus door/`requires`/sealed-door reserved cells
  (`roomlib.door_reserved_cells`) and internal gate slabs ± 2 along `facing`, plus the cell past
  the bounds from each pinned perimeter cell. A vertex is pinned if any zone cell's **closed**
  rect contains it.
- Chaikin with pins: per segment a→b — emit `a` if pinned; if both pinned emit nothing more; emit
  `a + (b−a)·r` if `a` free; emit `a + (b−a)·(1−r)` if `b` free. New points are unpinned.
- Roughen: per segment not pinned at both ends, `pieces = max(1, floor(len/ROUGH_STEP + 0.5))`,
  interior points `t = i/pieces`; skip (keep on the line) any point inside a pinned zone; amplitude
  `lerp(A(slot), A(slot+1), frac)` with `slot = floor(arc/SPAN)`, `A(k) = MIN + (MAX−MIN)·unit(hash32(seed, k, 1))`;
  offset `(unit(hash32(seed, floor(px+.5), floor(py+.5)))·2 − 1)·amp` along normal
  `(−dy, dx)/len`. Loop seed `hash32(room_seed(room_id), loop_index)`. Endpoints never move.
- `hash32`: FNV-1a over 32-bit words (`h ^= v & 0xFFFFFFFF; h = h·16777619 & M`), then
  `h ^= h>>16; h = h·0x7FEB352D & M; h ^= h>>15; h = h·0x297A2D39 & M; h ^= h>>16`. Multipliers
  are < 2³¹ so GDScript's signed 64-bit ints never overflow. `unit(h) = (h & 0xFFFF)/65535.0`.
  `room_seed`: FNV-1a over the id's UTF-8 bytes.
- Snap: `floor(v + 0.5)` (half up — never Python `round()` or anything banker's), drop consecutive
  duplicates. Do float maths in the same order as `walls.py`.

**Findings so far (go into the Phase 1 report):**
- Hollow narrowest passage **32 px in B and C** (player box is 30 px) — at **the neck** between
  the waking pocket and the crawl. The raw trace alone is 29 px (would seal the Hollow); corner
  cutting is what opens it. Margin is unspecified in the spec — flag it.
- A hard corner remains where a pinned apron meets a cut wall (Hollow exit) — spec asks to report.
- Python clearance is slow (~4 s Hollow, ~14 s Drip; Choir is 12× the Hollow) — fine for review
  tools, not for every lint run.
- Drip narrowest 59 px (its 2-tile exit slot). All eleven rooms: loops valid, footprints clear,
  pins held. Hollow and Drip seal on polygons.

---

## Phase 1 step 2 — the Godot twin (DONE; as built, see `hollow-pilot.md`)

**How the bevel is built today** (recon done, reported to owner): all three uses already share
one source, `RockBevel` (`scripts/rock/rock_bevel.gd`, pure, 23 tests in
`tests/test_rock_bevel.gd`) — but **per tile**, in the 47-tile blob atlas:
- drawing: `RockTileSet._draw_rock` carves pixels with `RockBevel.active`/`corner_signed`;
  `room.gd._build_tiles` paints the room with `set_cells_terrain_connect` (plus a rock ring);
- collision + occluder: `RockTileSet.build` gives each tile `RockBevel.tile_polygon` as its
  collision polygon and `OccluderPolygon2D`;
- look knobs: `scenes/rooms/rock_style.gd` (`RockStyle`), tones are `EnvPalette` names.

**Plan (proposed, not yet reviewed by the owner):**
1. `scripts/room/wall_outline.gd` — pure `RefCounted`, no nodes/autoloads, the five stages exactly
   as `walls.py`. It needs the pinned zones: port the zone maths it uses (apron/corridor slot,
   door rect + 2-tile approach, internal gate slab ± 2 along `facing`) from `roomlib.exempt_cells`
   / `door_reserved_cells`, reusing `RoomGeometry`'s constants. Keep it `--script`-testable (see
   memory: a class that names an autoload won't compile under `--script` — keep EnvPalette out).
2. Parity test `tests/test_wall_outline.gd`: fixture grids + the Hollow, compared vertex-for-vertex
   against loops exported by Python. Simplest: a small `scripts/export_wall_loops.py` that writes
   `tests/fixtures/wall_loops.json`, which the GDScript test reads. Also cover hash32 values.
3. Runtime flag: parse `--walls=smooth|bevel` from `OS.get_cmdline_user_args()` (debug builds only,
   like `world.gd`'s `--room=`); default `bevel`.
4. Smooth renderer in `room.gd` when the flag is `smooth` (keep `bevel` untouched):
   - floor: keep today's per-cell floor tiles (spatial-hash variants) — "floor rendering stays";
   - rock: draw the loops. Suggested approach: a rock-body fill behind everything (a `Polygon2D`
     over the padded bounds with a repeating rock-body texture), the floor tiles drawn only inside
     the outer floor loops, outcrop loops drawn as rock `Polygon2D`s on top, and the dark rim as a
     closed `Line2D` (1–2 px) per loop. **Antialiasing off** everywhere. Clipping the floor to the
     loop can be done with `clip_children` on a `Polygon2D` parent or by drawing rock *over*
     floor — check what works with the SubViewport + `CanvasModulate` + `PointLight2D` lighting and
     pick the simpler that renders correctly; report the choice.
   - collision: one `StaticBody2D` with a `ConcavePolygonShape2D` of explicit segment pairs per
     loop (closed);
   - occluders: one `LightOccluder2D` + `OccluderPolygon2D` (closed) per loop, same points.
   - All three from the one vertex list (spec: "one source").
5. Verify: `godot --headless --import`, all Godot tests (`./scripts/check_all.sh`), `--quit-after 90` with both
   `--walls=bevel` and `--walls=smooth`, Python suites. Then step 3 captures.

**Captures:** generalise `_capture_room.gd` to pass `--walls=` through (it instances
`scenes/main.tscn`, so the flag must be read where `room.gd` can see it). Existing usage:
`godot --path . res://_capture_room.tscn -- --cap=room_hollow --tag=v5 --close=14,4,15,13 "--at=4,12;18,12;20,13;22,12"`
(`--at` cells are dark shots; the first also gets a full-bright shot; `--close` is the 2× close-up
rect in tiles). **Must run windowed** — headless renders blank. Launch it in the background and
wait ~25 s; there is no `timeout` binary on this Mac.

---

## After smooth walls: resume the natural-walls batch

Order (spec, smallest to largest): **Overlook → Span → Stair → Choir** (Hollow and Drip done).
Per room: lint report + proposed grid → owner rules → apply → re-check every content cell (report,
never silently move) → `validate_rooms`, `seal_test`, `lint_rooms`, all Godot tests → capture.

- Thresholds (settled): straight run 3, unit steps 4, pipe ≤6 wide × 4, plus rule 3a `tooth`
  (any cell 1 tile thick with the other material on both opposite sides). Warnings, with owner
  baseline `data/lint_baseline.json`.
- Lessons from the Hollow/Drip: **features must be ≥2 tiles along the wall** (1-tile features
  render as V-spikes); build walls from 2–3 tile profile segments.
- `seal_test.py` only checks the Cistern's doors. For gated rooms, check seals with the flood fill
  (`walls.seal_problems`, or the scratch approach used for the Drip: `seal_test.reachable_bands`
  with the gate slab).
- Rock budget 20–30% (warning). Exceptions granted: throat rooms ~73% (Hollow only, not a
  precedent); Drip 33.3% (its exit slot).
- Room notes (natural-walls spec): **Overlook** — one composed screen, the chasm is looked
  *across* not down, keep its view toward the Choir's light (layout §2.1: Overlook/Choir vertical
  shaft alignment). **Span** — fissure and collapsed bridge read as one crossing, mended with note 3
  (the internal `n_mend` gate at `[40,8]` must still block). **Stair** — vertical descent past
  staggered ledges varied in width and spacing (so rule 2 doesn't catch a staircase), chime partway
  down, Door B at the bottom. **Choir** — tall and columned (regular columns are its identity; rule 3
  may flag the aisles as pipes — baseline them, don't fix), chimes at different heights, note 3 at
  the bottom, sealed passage east. Carved rooms get no reshaping.

**The batch is DONE (2026-09-28)** — record in `docs/m7-natural-walls/batch.md`.

---

## Authoring a room proposal — the method that worked (2026-09-28)

Learned across the Overlook, Span, Stair and Choir. Applies to the carved rooms next, minus the
natural-wall rules.

**The loop, per room:** draft in scratch → check → capture → record the round in `batch.md` → owner
rules → apply → re-check every content cell → `python3 scripts/export_wall_loops.py` →
`./scripts/check_all.sh` → commit. The owner reviews captures before approving; the room file is
not changed until a ruling.

**Drawing rims:**
- Use **low-frequency depth profiles**: depth changes by 1 per 2–3 tile segment, building a few
  big bends, with medium features (an alcove, a mass) on alternating walls. Random 2–3 tile notches
  pass the lint but render as a row of evenly spaced lobes — Overlook v1, Span v1 and Choir v1 all
  failed review that way.
- Segments of ≥2 can't make teeth or unit staircases; ≤3 keeps runs under the straight-run limit;
  depth steps of ≤3 keep the horizontal runs at each step under it too.
- Pin only the cells that must be floor next to an opening or door approach. Pinning a whole range
  to one depth makes a long straight run beside it.
- Chasms are `v`. An internal gate's crossing must sit inside its slab (72×90 px, centred on the
  gate's cell) and its exempt zone (slab ±2 along `facing`).

**Checking a draft** (before capturing): the lint with the note list; the wall-polygon checks
`check_all.sh` does not run — `walls.loop_problems`, `footprint_problems`, `pin_problems`,
`seal_problems`; for an internal gate, a `walls.reach` flood fill from each landing with its slab
shut vs open (`seal_problems` only closes doored/`requires` links). `scripts/check_room.py` wraps all
of this (`--grid FILE` checks a candidate without touching the room file). **As of 2026-09-29 it is
uncommitted:** its test takes minutes and would slow `check_all.sh`, so it needs a lighter fixture
first. `walls.narrowest` and the flood fills are slow on big rooms (the Choir and Cistern take
minutes) — don't loop them, and ask the owner before a long run.

**Captures for review:** write the grid into the room file, capture windowed, restore the room file
(`json.dumps(d, indent=2) + "\n"` round-trips the room files byte-identically). Godot on the command
line is `/Applications/Godot.app/Contents/MacOS/Godot` (`godot` is a shell alias). Flags are
`--key=value` only: a bare `--full` is ignored, the scene falls through to the shot path with no
`--at`, errors, and stays open — use `--full=1`, and wrap runs in a watchdog
(`perl -e 'alarm 150; exec @ARGV' <godot> …`). Check `project.godot` is unchanged afterwards. The
captures' `.import` files appear on the next import; commit them with the PNGs.

**Pushing:** a push carrying capture PNGs fails with HTTP 400 on the default buffer —
`git -c http.postBuffer=157286400 push origin main`. Push only when the owner asks.

---

## Open items flagged to the owner, not yet ruled

- **RESOLVED 2026-09-28 — a shut gate now draws a gap placeholder (see `docs/m7-natural-walls/batch.md`).** Was: **Ability gates are invisible in grey-box** (`AbilityGate` draws nothing): the Drip's key idea
  ("the exit is the gap you cross with note 2") can't be seen, and the stranger playthrough will
  bump into an invisible wall. A placeholder look needs an owner ruling (Godot visual).
- **Note 1 visible from frame one** — recorded as an open M8 question in `hollow-pilot.md`
  (accept vs wake the pickup light at the low bend). The M7 playthrough tests it as-is.
- **RESOLVED (found 2026-10-06):** internal `ability_gates[].note` *is* validated, by the lint
  against `notes.json` (`lint_rooms.py`) and at boot by `RoomGraph` (`room_graph.gd`).
- `data/melodies/door_backtrack.json` is orphaned (loaded, referenced by nothing).
- `scripts/new_room.py` doesn't register the room in `rooms.json` (spec said it would).
- In true world coordinates the loop doesn't close (the Choir sits ~108 tiles below the Cistern,
  the Span beside it must sit ~36 below). Harmless now; matters if a map screen is ever built.
- **RESOLVED:** the CLAUDE.md "one rule" grep now uses `^(\./)?(tests|…)`.

## Content finalisation (2026-10-06) — DONE

Audit of every room against spec §4.2–4.3 after carving. Everything placed matches: pickups
`n_break` Hollow, `n_step` Drip, `n_mend` Choir (bottom), none left in the Gallery; chimes for Door A
(Cistern hub), Door B (partway down the Stair), Door C (Span), and Door Ω's three path-order
fragments (Drip, Overlook, Choir; the Choir echoes its fragment high, middle and low, `d93747d`);
the Drip and Span ability gates; sealed doors on the Cistern S, Choir E, Antechamber W (2026-10-06,
decorative) and Resonance E, plus the Resonance core's boss door. The carved rooms hold no other
content. Station markers are dropped (owner). `check_all.sh` 18/18 covers what can be checked:
content on floor and clear of reserved footprints (lint), clear of the wall polygons (`test_walls`),
graph solvability and the melody pitch-class rule (`validate_rooms`), seals, boot.

Not decided: whether to delete the orphaned `door_backtrack` melody (the owner's data).

## Still ahead in M7 after both steps

Cistern fifth opening + the one-way shortcut (Step 3a; Threshold's N edge col 15 ↔ Cistern S col
~22), content finalisation incl. Resonance's three station markers, **the stranger playthrough (not
waivable)**, then close M7 (`docs/m7-progress.md`, CLAUDE.md/README trim).
