# Decisions and history

History and long rationale moved out of `CLAUDE.md` in the 2026-09-28 restructure
(`docs/claude-md-restructure/inventory.md`). Nothing here is needed to write code; the rules
these produced live in `CLAUDE.md` and `.claude/rules/`. Newest first within each section.

---

## Milestone history

**M6 — authoring pipeline + room two (closed 2026-09-21, gate met).** Resolved: room two was the
**Gallery (`room_b`)**; hours-per-room measurement **dropped** (no deadline); the Gallery is a
**dim traversal shelf** (doorless → no light beacon, by design); rubble cap ≤6; reference stills
captured via a throwaway windowed scene, no debug capture key re-added to the shipped input path.
The other pipeline candidates (preview, scaffold, jump-to-room) were **not** built in M6 — recon
didn't justify them for one room. M7 later added jump-to-room (`--room=`) and a scaffold
(`new_room.py`). At M6's close two rooms were built and nine remained; M6's pipeline made those
nine cheaper to author. Record: `docs/m6-progress.md`.

**M5 — the cave look (closed 2026-09-20, store-page gate met).** M4's store-page gate was deferred
into M5 and met there — recorded, not collapsed. The hours-per-room projection was dropped with
the deadline (2026-09-20). Record: `docs/m5-progress.md`, which stays: the M7 spec, `seal_test.py`
and README cite it.

**M4 — technical visual foundation (closed 2026-09-18 as a code milestone).** Delivered the
fixed-resolution render pipeline, `EnvPalette` (the one rule extended to environment colour), the
Silkscreen font, dynamic lighting with the player's light growing on collection, distinct object
silhouettes (D-M4-7 fixed) and the motion pass including the door-unlock choreography. Its drawn
art and store-page gate went to M5.

**Archived records.** Build specs and records for M0–M4 were archived out of the repo at M6
(kept by the owner).

**Internal resolution history.** 320×180, then 640×360, both in M4; bumped to 960×540 the same
day it was approved (2026-09-18, Q27). 360 is the only height dividing 1080, 1440 and 2160, so
the bump to 540 traded away integer-clean 1440p; the Display's integer-prescale + bilinear
resample landed in M5 Step 0.

---

## The M3 play-through gate waiver (owner, 2026-09-18)

The gate was *a stranger gets the loop unprompted*. It is waived rather than run, on the record,
for two reasons. The two things it would most likely have caught are already fixed — chimes
reading as dimmed pickups (D-M4-7) and the gem-hue disagreement (D-M3-3, ruled intended). And
M7's grey-box map carries a strictly stronger version — a stranger playing the full eleven-room
map — whose scarce resource, a fresh pair of eyes, would be wasted on a map about to be
superseded. The residual risk is real and accepted: the loop's legibility is unvalidated until
M7, and M7's gate must not be waived in turn.

---

## Long rationale

**Colour: four shades per category, rejected.** Four shades of one hue per category were
indistinguishable on a 6px door gem against a dark background; one contiguous hue arc per
category keeps twelve distinct hues so a single note stays identifiable while the family reads
at a glance.

**The instrument-state piano layout.** It beats the `Z X C V B N M` tracker row: on the home row
the hand rests and the thumb falls on space without moving, whereas on the tracker row the hand
shifts down and the thumb jams against the front edge. It is not the DAW convention — prior FL
Studio habits don't carry; the unbound `R`/`I` gaps buy discoverability instead.

**Rhythm-synced gameplay, rejected.** It would make melodies un-swappable, and M1's latency
measurements (40ms engine-side, plus 100–300ms on Bluetooth) make it unplayable for wireless
users anyway.
