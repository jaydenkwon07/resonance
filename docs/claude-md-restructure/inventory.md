# CLAUDE.md restructure — inventory

Source: `CLAUDE.md` at 830 lines (2026-09-28), after the /init fix pass. One row per atomic
item: a short paraphrase, the source line range, and exactly one destination. Items that were
split carry a letter suffix. `STALE` marks a line with a Phase 1 finding (see the report); its
destination applies once the fix is approved.

Destinations: `ROOT` · `RULE:rooms` · `RULE:music` · `RULE:input` · `RULE:lighting` ·
`COMMENT:synth.gd` · `DOC:docs/decisions.md` · `DELETE` (with reason / surviving copy).

The `[M4]`/`[M5]`/`[M6]`/`[M7]` provenance tags throughout are DELETE (history; git has it) and
aren't listed per line.

Phase 2 (2026-09-28): every row marked done with its final location. `CLAUDE.md` 830 → 281 lines.

## §0 Header

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 1 | "Working agreement. Read fully before writing code." | 1–3 | ROOT | done → CLAUDE.md header |

## §1 What this is

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 2 | Game pitch: 2D top-down music game, notes the only verb, melody doors, metroidvania; tonal refs | 9–12 | ROOT | done → CLAUDE.md §1 |
| 3 | Solo dev composing the score; experienced programmer new to Godot — explain engine, not programming | 14–16 | ROOT | done → CLAUDE.md §1 |
| 4a | Internal res 960×540 SubViewport, ×2→1080p, ×4→4K; pixel art, keyboard only, PC | 18–20 | ROOT | done → CLAUDE.md §1 |
| 4b | Resolution history (320×180 → 640×360 in M4) | 19 | DOC:docs/decisions.md | done → docs/decisions.md |
| 5 | 1440p not integer-clean; Display integer-prescales then bilinear resample | 22–25 | ROOT | done → CLAUDE.md §1 |
| 6 | First deliverable ~30 min Act 1 cave demo, 3–5 notes; episodic; don't design for the full game | 27–29 | ROOT | done → CLAUDE.md §1 |
| 7 | Design doc lives outside repo; it wins on disagreement — say so | 31–34 | ROOT | done → CLAUDE.md §1 |

## §2 Current state

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 8a | Runs clean on Godot 4.7.2 | 40 | ROOT | done → CLAUDE.md §1 |
| 8b | M0–M2 narrative | 40–43 | DELETE — dup of §8 ladder rows M0–M2 | done → deleted |
| 9 | M3 feature list | 45–48 | DELETE — derivable from code; status survives in ladder M3 row | done → deleted |
| 10a | Full M3 waiver argument (D-M4-7, D-M3-3, fresh eyes) | 50–57 | DOC:docs/decisions.md | done → docs/decisions.md |
| 10b | Residual risk accepted; M7's gate must not be waived | 55–57 | ROOT | done → CLAUDE.md §2 |
| 11 | M4 closed as code milestone; feature list; art deferred to M5 | 59–63 | DOC:docs/decisions.md | done → docs/decisions.md |
| 12a | M5 closed, store-page gate met, record path | 65–66 | DELETE — dup of ladder M5 row | done → deleted |
| 12b | `cistern-final.png` is the quality bar for every later room | 66–67 | ROOT | done → CLAUDE.md §5 |
| 13 | Rock/floor are a procedural `RockAtlas`, kept generating so `palette.json` retints; the only file that knows the look | 69–70 (+227–230) | RULE:lighting | done → .claude/rules/lighting.md |
| 14a | Walls = smoothed loops (trace→pin→Chaikin→roughness→snap), twin of `walls.py`; one vertex list = drawing, collision, occluder | 70–73 | RULE:rooms | done → .claude/rules/rooms.md |
| 14b | Bevel + 47-tile blob retired 2026-09-26 | 73–74 | DELETE — dup of item 161 (do-not-reopen) | done → deleted |
| 15 | 5 hard light bands, vignette after upscale, bloom off, no static lights, every object emits, doors are beacons | 75–76 | RULE:lighting | done → .claude/rules/lighting.md |
| 16 | Cistern (`room_a`, 48×36) geometry LOCKED; what an edit must preserve | 77–79 | RULE:rooms | done → .claude/rules/rooms.md |
| 17a | Doors composed of DoorArt/DoorGems oriented via DoorLayout | 80 | DELETE — derivable from `door.gd` | done → deleted |
| 17b | DOOR_INSET 1.5 from the link cell | 81 | DELETE — dup of item 109 | done → deleted |
| 17c | An opened door stays a lit landmark | 81–82 | RULE:lighting | done → .claude/rules/lighting.md |
| 18 | S exit is a decorative SealedDoor; "schema-level sealed exit waits for M7" | 82–83 | RULE:rooms — **STALE S2** | done → .claude/rules/rooms.md; S2 applied |
| 19 | Rubble is a decorative Prop, Cistern ≤5 | 83 | RULE:rooms | done → .claude/rules/rooms.md |
| 20a | M5 art is provisional; redesigned in M8/M9/M10/M13 and by owner | 84–86 | RULE:lighting | done → .claude/rules/lighting.md |
| 20b | Owner's standing priority: layout and mechanics before art polish | 86–87 | ROOT | done → CLAUDE.md §2 |
| 21a | M6 closed, gate met, record/recipe paths | 89–92 | DELETE — dup of ladder M6 row | done → deleted |
| 21b | `gallery-final.png` reference still | 91 | RULE:rooms | done → .claude/rules/rooms.md |
| 22 | Gallery (`room_b`, 96×18) geometry LOCKED; preserve openings, entries, "aprons", rock ~30.5% | 94–96 | RULE:rooms — **STALE S11** | done → .claude/rules/rooms.md; S11 applied |
| 23 | Pipeline = RoomGeometry/RoomContent + `lint_rooms.py` on `roomlib.py`; run lint after any room change; green before freeze | 97–100 | RULE:rooms | done → .claude/rules/rooms.md |
| 24 | Preview/scaffold/jump-to-room not built in M6; M7 added two | 100–102 | DOC:docs/decisions.md | done → docs/decisions.md |
| 25a | Gallery is a dim traversal shelf: doorless → no beacon; a finding, not a gap | 103–104 | RULE:lighting | done → .claude/rules/lighting.md |
| 25b | Gallery rubble cap ≤6 (5 placed) | 104–105 | RULE:rooms | done → .claude/rules/rooms.md |
| 26 | M0–M4 records archived; `m5-progress.md` stays while leaned on | 107–108 | DOC:docs/decisions.md — **STALE S5** | done → docs/decisions.md; S5 applied |
| 27a | Current milestone M7; spec + plan paths | 110–112 | ROOT | done → CLAUDE.md §2 |
| 27b | What the M7 spine contains (schema, new_room, eleven rooms, doors, room_c/d retired, checks green) | 112–118 | DELETE — derivable from code/git; status in ladder M7 row | done → deleted |
| 28 | Resuming M7 → read HANDOFF.md first; smooth walls done; next natural-walls batch order | 120–122 | ROOT | done → CLAUDE.md §2 |
| 29 | Remaining: carve open boxes; Cistern 5th opening + shortcut (C1, the one sanctioned edit to frozen geometry); stranger gate MUST NOT be waived; close M7 | 124–127 | ROOT — **STALE S6** | done → CLAUDE.md §2; S6 applied |
| 30a | Author new rooms with `room-authoring.md` | 128 | ROOT | done → CLAUDE.md §5 |
| 30b | A new room needs its own `.tscn` | 128 | DELETE — dup of item 105 | done → deleted |
| 31 | Span prerequisite: NoteRegistry check for `ability_gates[].note` before carving full-height | 129–131 | ROOT | done → CLAUDE.md §2 |
| 32 | M1 aesthetic gate: first real instrument voice → stop and run the gate | 133–137 | ROOT | done → CLAUDE.md §2 |
| 33 | Render root `main.tscn`; bare SubViewport doesn't forward input; new input nodes go through `push_input` | 139–143 | ROOT | done → CLAUDE.md §4 |

## §3 The one rule

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 34 | No pitch, melody or musical pattern in a `.gd` file | 149 | ROOT | done → CLAUDE.md §3 |
| 35 | Why: ids in code, pitches in data; owner rewrites melodies without code changes | 151–154 | ROOT | done → CLAUDE.md §3 |
| 36 | The verification grep + two exemptions (tests/, note_names.gd) | 156–165 | ROOT — **STALE S7** | done → CLAUDE.md §3; S7 applied |
| 37 | Corollary: world objects reference a note id or palette slot | 168 | ROOT | done → CLAUDE.md §3 |
| 38 | Corollary: keyboard→pitch mapping is data | 169–170 | ROOT | done → CLAUDE.md §3 |
| 39 | Corollary: categories and colours come from `notes.json` | 171–172 | ROOT | done → CLAUDE.md §3 |

## §4 Architecture

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 40 | Autoload tree lines (input_config … world_state) | 180–188 | DELETE — derivable from `project.godot` + file headers; README Layout also lists them | done → deleted |
| 41 | EnvPalette: no hex literal in a scene or script | 189–190 | ROOT | done → CLAUDE.md §4 |
| 42 | `scripts/music/` tree with PURE flags | 191–195 | DELETE — dup of item 81 (pure-seam list) | done → deleted |
| 43 | `room_geometry.gd` tree line; "the lint will mirror" | 196–199 | DELETE — dup of items 81/70 — **STALE S3** | done → deleted; S3 applied |
| 44a | `wall_*.gd` stages; vertex parity with `walls.py` via `test_wall_outline` | 200–203 | RULE:rooms | done → .claude/rules/rooms.md |
| 44b | Overhang/silhouette layers are M9, not built | 204 | DELETE — dup of ladder M9 row | done → deleted |
| 45 | `project.godot`'s main scene is `main`, not `world` | 206–209 | ROOT | done → CLAUDE.md §4 |
| 46a | `world.tscn` hosts rooms, camera clamp | 210–212 | DELETE — derivable | done → deleted |
| 46b | Backtick = full-bright debug toggle | 212 | ROOT | done → CLAUDE.md §6 |
| 47 | `player/` tree line | 213 | DELETE — derivable | done → deleted |
| 48 | Floor variant is a spatial hash, not RNG, or rooms change each re-instance | 214–217 | RULE:rooms | done → .claude/rules/rooms.md |
| 49a | room_walls: collision + occluder from the one vertex list | 218–220 | DELETE — dup of item 14a | done → deleted |
| 49b | Floor painted over rock, no clipping | 220 | RULE:rooms | done → .claude/rules/rooms.md |
| 50 | `RockStyle` is the tuning surface for the cave look | 221–222 | RULE:lighting | done → .claude/rules/lighting.md |
| 51a | New content types go in `RoomContent`, not `room.gd` | 223–225 | RULE:rooms | done → .claude/rules/rooms.md |
| 51b | `room.gd`/`room_content.gd` don't compile under `--script` (reach EnvPalette) | 225–226 | ROOT (with item 81b) | done → CLAUDE.md §4 |
| 52 | rock_atlas generates; owner chose not to load a PNG | 227–230 | DELETE — dup of item 13 | done → deleted |
| 53 | note_ring presentational + light | 231 | DELETE — derivable | done → deleted |
| 54 | `lighting.gd` shared factory; gradient quantised to hard bands — smooth blur is the one non-pixel thing | 232–235 | RULE:lighting | done → .claude/rules/lighting.md |
| 55 | particle_burst, collect_flash lines | 236–237 | DELETE — derivable | done → deleted |
| 56 | ui/ tree lines | 238–241 | DELETE — derivable | done → deleted |
| 57 | interactable.gd = base contract | 242 | DELETE — dup of item 129 | done → deleted |
| 58 | resonator gates on effects_enabled | 243 | DELETE — derivable; rule survives as item 132 | done → deleted |
| 59 | Pickup animates in `_draw` so collision and interact_point never move | 244–247 | ROOT | done → CLAUDE.md §4 |
| 60 | Chime resting form is stone, tints only while ringing; resonant materials doors-only in Act 1 | 248–251 | RULE:music | done → .claude/rules/music.md |
| 61 | room_link edge-band trigger | 252–253 | DELETE — dup of item 107 | done → deleted |
| 62 | MelodyLock holds NO matching logic | 254–255 | RULE:music | done → .claude/rules/music.md |
| 63a | `Door.CATEGORY_REP_INDEX` stays in door.gd — the keyboard strip uses it | 256–260 | RULE:music | done → .claude/rules/music.md |
| 63b | door.gd owns choreography + brass frame light, doors brightest | 257–258 | DELETE — derivable / dup of item 15 | done → deleted |
| 64 | Opened door's gems stay LIT | 261–263 | DELETE — dup of item 17c | done → deleted |
| 65 | door_art description | 264–266 | DELETE — derivable | done → deleted |
| 66 | door_layout PURE | 267–268 | DELETE — dup of item 81 | done → deleted |
| 67 | sealed_door: five UNLIT sockets | 269–270 | DELETE — dup of item 18 | done → deleted |
| 68 | Prop: no collision/light/interaction, spatial-hash shape; cracks deferred | 271–272 | RULE:rooms | done → .claude/rules/rooms.md |
| 69 | AbilityGate: not an Interactable, opens on ownership, no WorldState; built from `requires` or `ability_gates`; visible behaviour is M11 | 273–278 | RULE:rooms | done → .claude/rules/rooms.md |
| 70 | Python tools' roles; `roomlib.py` is the one place the door/opening/landing maths lives | 279–285 | RULE:rooms | done → .claude/rules/rooms.md |
| 71 | `walls.py` is the parity twin; `export_wall_loops.py` rewrites the fixture | 285–287 | RULE:rooms | done → .claude/rules/rooms.md |
| 72 | tlog.py optional time log | 287 | DELETE — derivable; hours measurement dropped | done → deleted |
| 73 | `migrate_rooms_2x.py` is a spent one-off — don't run it | 287–288 | RULE:rooms | done → .claude/rules/rooms.md |
| 74 | Python tests are stdlib unittest, list | 288–290 | DELETE — `check_all.sh` runs them | done → deleted |
| 75 | Lint baseline `data/lint_baseline.json` is the OWNER's list; never add to go green | 291–292 | RULE:rooms | done → .claude/rules/rooms.md |
| 76 | data/ tree: rooms.json graph, rooms/<id>.json | 293–294 | DELETE — dup of item 101 | done → deleted |
| 77 | tests: 182 in six files | 295 | DELETE — no hard-coded counts; `check_all.sh` | done → deleted |
| 78 | docs/ tree, cistern-final | 296–297 | DELETE — dup of item 12b | done → deleted |
| 79 | EnvPalette resolves names from `palette.json`; unknown name → magenta = misspelling | 300–303 | ROOT | done → CLAUDE.md §4 |
| 80 | Pure seam: no nodes, signals, engine state; unit-testable without the engine | 307–309 | ROOT | done → CLAUDE.md §4 |
| 81a | Pure-seam file list (note_names, melody_matcher, note_colors, door_layout, room_geometry, wall_*, instrument_keyboard_layout) | 310–315 | ROOT | done → CLAUDE.md §4 |
| 81b | Why extracted: callers referencing EnvPalette can't compile under `--script` | 311–312 | ROOT | done → CLAUDE.md §4 |
| 82a | If pure code seems to need a node ref, the logic belongs in the caller | 317–318 | ROOT | done → CLAUDE.md §4 |
| 82b | NoteColors takes category/index; the lookup is NoteRegistry's | 318–320 | RULE:music | done → .claude/rules/music.md |
| 83 | React to notes via `NoteBus.note_played`, never a player reference | 324–325 | ROOT | done → CLAUDE.md §4 |
| 84 | `set_instrument_state` / `effects_enabled()` gate gameplay effects | 327–328 | ROOT (merged with item 132 as one line) | done → CLAUDE.md §4 |
| 85 | `MelodyMatcher.evaluate` → {result, progress}; progress lights gems one at a time | 332–334 | RULE:music | done → .claude/rules/music.md |
| 86 | Match-rules table (order, octave, transposition, timing reserved) | 336–341 | RULE:music | done → .claude/rules/music.md |
| 87 | Tune difficulty by editing rules, never by code branches | 343 | RULE:music | done → .claude/rules/music.md |

## §5 Data formats

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 88 | `notes.json` is canonical; everything resolves category/colour/pitch through it | 349–352 | RULE:music | done → .claude/rules/music.md |
| 89 | notes.json JSON example | 354–362 | DELETE — derivable from `data/notes.json` | done → deleted |
| 90 | `pitch_class` is a letter, not a pitch | 364 | RULE:music | done → .claude/rules/music.md |
| 91 | `category` enum | 365 | RULE:music | done → .claude/rules/music.md |
| 92 | `index` 0–3; with category sets hue | 366–367 | RULE:music | done → .claude/rules/music.md |
| 93 | Melody JSON example | 371–389 | DELETE — derivable from `data/melodies/door_tutorial.json` | done → deleted |
| 94 | `notes` and `rhythm` separate | 391 | RULE:music | done → .claude/rules/music.md |
| 95 | `key`/`mode`/`finale_role` read by nothing; don't remove, don't build on | 392–393 | RULE:music | done → .claude/rules/music.md |
| 96 | `placeholder: true` — never clear it; startup prints count | 394–395 | RULE:music | done → .claude/rules/music.md |
| 97 | `hint.color_sequence` dropped; re-add only deliberately as an override | 396–399 | RULE:music | done → .claude/rules/music.md |
| 98 | Palette `data/palettes/starter.json`; not the env palette | 401–405 | **STALE S8** — proposed DELETE | done → deleted (env-palette distinction kept in .claude/rules/lighting.md); S8 applied |
| 99 | `keyboard_layout.json`: `piano` + `palette` sections, one loader | 409–416 | RULE:input | done → .claude/rules/input.md |
| 100 | Never hardcode a key's printed letter; labels via `keyboard_get_label_from_physical()` | 418–421 | ROOT | done → CLAUDE.md §4 |
| 101 | `rooms.json` = graph, `rooms/<id>.json` = geometry; validator never boots the engine | 425–428 | RULE:rooms | done → .claude/rules/rooms.md |
| 102 | Rooms variable-size, 30px tiles, camera clamps; 32×18 = one screen | 430–431 | RULE:rooms | done → .claude/rules/rooms.md |
| 103 | Room file fields (grid chars, entries, links door XOR requires, pickups, chimes, ability_gates, sealed_doors, props) | 433–439 | RULE:rooms | done → .claude/rules/rooms.md |
| 104 | `requires` must be in BOTH graph exit and geometry link; RoomGraph cross-checks | 439–441 | RULE:rooms | done → .claude/rules/rooms.md |
| 105 | Every room needs `scenes/rooms/<id>.tscn`; nothing catches a missing one; verify with `--quit-after 90` | 441–444 | RULE:rooms | done → .claude/rules/rooms.md |
| 106 | Author subtractively; 20–30% unreachable rock | 446–447 | RULE:rooms | done → .claude/rules/rooms.md |
| 107 | Edge-band transitions, mirrored landing, 2-tile openings | 449–453 | RULE:rooms | done → .claude/rules/rooms.md |
| 108 | Only the exit mouth must be straight floor (owner 2026-09-26) | 453–455 | RULE:rooms | done → .claude/rules/rooms.md |
| 109 | Door placement derived: DOOR_INSET 1.5, DOOR_ENTRY_INSET 3.5 | 457–459 | RULE:rooms | done → .claude/rules/rooms.md |
| 110 | Door footprint, 2-tile approach and stub hold no content | 460–461 | RULE:rooms | done → .claude/rules/rooms.md |
| 111 | Content coordinates are absolute; re-check after any geometry change | 461–462 | RULE:rooms | done → .claude/rules/rooms.md |
| 112 | Synth mix ÷ √voices, eased | 466–473 | COMMENT:synth.gd | done → autoload/synth.gd header |
| 113 | Voice cleanup `env <= 0 AND age >= attack` | 474–475 | COMMENT:synth.gd | done → autoload/synth.gd header |
| 114 | Buffer 0.04s latency/dropout trade | 476–477 | COMMENT:synth.gd | done → autoload/synth.gd header |
| 115 | Waveform is a placeholder sine; swap it behind NoteBus | 479–481 | COMMENT:synth.gd | done → autoload/synth.gd header |

## §6 Design decisions

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 116 | Collect pitch classes; chromatic; twelve notes | 487–489 | RULE:music | done → .claude/rules/music.md |
| 117 | Why twelve (3×4); octave is range; `octave_matters` defaults false | 491–495 | RULE:music | done → .claude/rules/music.md |
| 118 | Hue from (category, index), never semitone | 497–499 | RULE:music | done → .claude/rules/music.md |
| 119 | Category arc table | 501–505 | RULE:music | done → .claude/rules/music.md |
| 120a | Twelve distinct hues; octave sets brightness | 507–510 | RULE:music | done → .claude/rules/music.md |
| 120b | Four-shades-per-category rejected (6px gem) | 508–509 | DOC:docs/decisions.md | done → docs/decisions.md |
| 121 | Colour is the primary display channel for melodies; no staff | 512–513 | RULE:music | done → .claude/rules/music.md |
| 122 | Accessibility deferred; colour is the one carve-out | 515–518 | ROOT | done → CLAUDE.md §4 |
| 123 | Owning is not wielding; five equipped; never assume owned == equipped | 520–524 | RULE:music — **STALE S9** | done → .claude/rules/music.md; S9 applied |
| 124 | Doors show structure, never content | 526–530 | RULE:music | done → .claude/rules/music.md |
| 125a | No ability behaviours before M11; geometry only needs the seam | 535–538 | ROOT | done → CLAUDE.md §4 |
| 125b | Category = family of purpose; ~12 behaviours; door-only notes legitimate | 532–535 | RULE:music | done → .claude/rules/music.md |
| 126 | Melody length ramp 1→1 … 6→5, ceiling 5–6; authoring convention | 540–543 | RULE:music | done → .claude/rules/music.md |
| 127 | No failure cost; guessable early doors fine | 545–547 | RULE:music | done → .claude/rules/music.md |
| 128 | `space` is the master key; never a second interaction key — use Interactable | 549–551 | ROOT | done → CLAUDE.md §4 |
| 129 | Interactable resolution: instrument state wins, else nearest in range, one per press | 553–557 | ROOT | done → CLAUDE.md §4 |
| 130 | Interact prompt ships with the first interactable (cold open) | 559–561 | ROOT | done → CLAUDE.md §4 |
| 131 | Interactables distinguishable by silhouette; black-on-white test | 563–569 | ROOT | done → CLAUDE.md §4 |
| 132 | Instrument state suspends movement; check `effects_enabled()` before gameplay-visible effects | 571–574 | ROOT | done → CLAUDE.md §4 |
| 133 | Ocarina model: overlay, world runs, instant free cancel, no fade | 574–576 | RULE:input | done → .claude/rules/input.md |
| 134 | Two input modes table | 578–583 | RULE:input | done → .claude/rules/input.md |
| 135 | Palette mirrors movement layout table | 585–591 | RULE:input | done → .claude/rules/input.md |
| 136a | Low-to-high; `'` is the sixth; number row reserved for loadout | 593–596 | RULE:input — **STALE S9** | done → .claude/rules/input.md; S9 applied |
| 136b | "Same keys in both layouts" abandoned — home row beats consistency | 594–595 | RULE:input (one clause) | done → .claude/rules/input.md |
| 137 | Piano layout table | 598–604 | RULE:input | done → .claude/rules/input.md |
| 138 | R and I unbound; range C4–E5 | 606–608 | RULE:input | done → .claude/rules/input.md |
| 139a | One layout for both modes; thumb on space; not DAW convention (short) | 610–617 | RULE:input | done → .claude/rules/input.md |
| 139b | Long rationale (tracker row, FL Studio habits) | 613–617 | DOC:docs/decisions.md | done → docs/decisions.md |
| 140 | On-screen key hints must be mode-aware | 619–622 | RULE:input | done → .claude/rules/input.md |
| 141 | Interact `space`; Escape layered; `[`/`]` octave; F1 reserved | 624–627 | RULE:input — **STALE S10** | done → .claude/rules/input.md; S10 applied |
| 142 | Rebindable: never hardcode a key in a scene; register in `input_config.gd`, physical keycodes | 629–631 | ROOT | done → CLAUDE.md §4 |
| 143a | Placeholder-first: never couple code to specific music; rhythm-sync rejected | 633–634 | ROOT | done → CLAUDE.md §4 |
| 143b | Latency numbers (40ms + 100–300ms BT) | 635–636 | DOC:docs/decisions.md | done → docs/decisions.md |

## §7 Milestone history

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 144 | M2–M4 archived; `m5-progress.md` "while M6 leans on it" | 642–644 | DOC:docs/decisions.md — **STALE S5** | done → docs/decisions.md; S5 applied |
| 145 | Per-milestone history lines M2–M6 | 646–658 | DELETE — dup of §8 ladder | done → deleted |
| 146 | "Don't summarize build steps here" | 651–652 | DELETE — dup of item 188 (trim rule) | done → deleted |

## §8 Milestone ladder

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 147 | Rooms split by fidelity pass, systems by system; a room needs only a gate's seam | 664–666 | ROOT | done → CLAUDE.md §9 |
| 148 | Ladder table M0–M14 | 668–684 | ROOT (cells trimmed to status/gate; M7 detail lives in "Now") | done → CLAUDE.md §9 |
| 149 | One room first, then the batch, inside every pass | 686–689 | ROOT | done → CLAUDE.md §9 |
| 150 | M4 gate met in M5; "two built, nine remain"; hours projection dropped | 691–693 | DOC:docs/decisions.md — **STALE S4** | done → docs/decisions.md; S4 applied |

## §9 Owner's calls

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 151 | Open questions: implement nothing and ask | 699–700 | ROOT | done → CLAUDE.md §8 |
| 152 | Pitch class → category mapping; flagged placeholders; don't fill twelve | 702–705 | ROOT | done → CLAUDE.md §8 |
| 153 | Does combat exist | 706–707 | ROOT | done → CLAUDE.md §8 |
| 154 | What each note does | 708–709 | ROOT | done → CLAUDE.md §8 |
| 155 | Convergent finale — code must never assume it | 710–712 | ROOT | done → CLAUDE.md §8 |
| 156 | How the player learns a melody; other vectors deferred | 713–715 | ROOT — **STALE S1** | done → CLAUDE.md §8; S1 applied |
| 157a | Resolved in M6 (Gallery, hours dropped, dim shelf, rubble ≤6) | 717–721 | DOC:docs/decisions.md | done → docs/decisions.md |
| 157b | No debug capture key re-added to the shipped input path | 720–721 | ROOT (do-not-reopen) | done → CLAUDE.md §8 |
| 158 | Do-not-reopen: collection, colour, same-category differ, ramp, no failure cost, top-down, instrument state, two input modes | 725–727 | ROOT | done → CLAUDE.md §8 |
| 159 | Internal resolution 960×540 approved (Q27) | 728–730 | ROOT | done → CLAUDE.md §8 |
| 160 | Art direction: lithic base, resonant doors | 731 | ROOT | done → CLAUDE.md §8 |
| 161 | Walls option C; M3 gate waived | 732–733 | ROOT | done → CLAUDE.md §8 |
| 162 | From M5: bands/bloom/static; S door decorative; 960×540 not too tight (Q25); Cistern locked; art provisional | 734–737 | ROOT — **STALE S2** | done → CLAUDE.md §8; S2 applied |

## §10 Conventions, commands, scenes

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 163 | Static types | 743 | ROOT | done → CLAUDE.md §7 |
| 164 | Files ~200 lines, split before | 744 | ROOT | done → CLAUDE.md §7 |
| 165 | `##` doc comments, why over what | 745 | ROOT | done → CLAUDE.md §7 |
| 166 | Naming | 746 | ROOT | done → CLAUDE.md §7 |
| 167 | `@export` feel numbers | 747 | ROOT | done → CLAUDE.md §7 |
| 168 | Signals over cross-system refs | 748 | ROOT | done → CLAUDE.md §7 |
| 169 | Test every match rule / pure function touched | 749 | ROOT | done → CLAUDE.md §7 |
| 170 | Envelope bug pattern; gems, ring alpha, resonator glow share it | 750–754 | ROOT | done → CLAUDE.md §7 |
| 171 | `godot --headless --import` first | 759 | ROOT (in `check_all.sh` + listed) | done → CLAUDE.md §6 |
| 172 | `godot .` to see print output | 760 | ROOT | done → CLAUDE.md §6 |
| 173 | `--room=<id> [--spawn=]` | 761 | ROOT | done → CLAUDE.md §6 |
| 174 | Six Godot test commands + counts | 762–767 | ROOT via `check_all.sh`; counts DELETE | done → CLAUDE.md §6 + scripts/check_all.sh |
| 175 | `--quit-after 90` boot run | 768 | ROOT | done → CLAUDE.md §6 |
| 176 | Python checks + tests | 769–775 | ROOT via `check_all.sh` | done → CLAUDE.md §6 + scripts/check_all.sh |
| 177 | `export_wall_loops.py` | 776 | DELETE — dup of item 71 | done → deleted |
| 178 | One-rule grep in the check list | 779 | ROOT (in `check_all.sh`) | done → CLAUDE.md §3 + scripts/check_all.sh |
| 179 | Last Godot test line is an object.cpp warning | 781–782 | ROOT | done → CLAUDE.md §6 |
| 180 | CI runs only `validate_rooms.py` | 784–786 | ROOT | done → CLAUDE.md §6 |
| 181 | `_capture_room.*` — never commit | 788–790 | ROOT | done → CLAUDE.md §6 |
| 182 | Prefer `godot .` over F5 | 792–793 | ROOT | done → CLAUDE.md §6 |
| 183 | Say so when you edit a `.tscn` (editor save reverts) | 797–800 | ROOT | done → CLAUDE.md §7 |

## §11 Scope discipline

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 184 | Main risk is too much too early; non-goals are real | 806–808 | ROOT | done → CLAUDE.md §10 |
| 185 | Don't build ahead of the milestone (examples) | 810–813 | ROOT | done → CLAUDE.md §10 |
| 186 | Mis-scoped → say so and stop | 815–816 | ROOT | done → CLAUDE.md §10 |

## §12 Keeping this file honest

| # | Item | Lines | Dest | Status |
|---|---|---|---|---|
| 187 | On milestone completion: update this + README, write `docs/mN-progress.md` | 822–824 | ROOT | done → CLAUDE.md §10 |
| 188 | Trim, don't append | 826–831 | ROOT | done → CLAUDE.md §10 |
