#!/usr/bin/env python3
"""One room's full authoring check: the lint (with the note list and the owner's baseline), the
wall-polygon checks check_all.sh doesn't run (loops, footprints, pins, seals), the narrowest
passage (opt-in: it is slow on big rooms), and whether each internal ability gate actually cuts
something off. `--grid` checks a
candidate grid (one row per line) against the room's content without writing the room file, so a
proposal can be judged before it's applied.

    python3 scripts/check_room.py room_span
    python3 scripts/check_room.py room_span --grid candidate.txt
    python3 scripts/check_room.py room_span --narrowest

Exit non-zero on any error; warnings (rock budget, wall rules) are printed but don't fail.
"""

from __future__ import annotations

import copy
import json
import sys

import roomlib
import walls
from lint_rooms import lint_room, load_baseline


def internal_gate_problems(data: dict, loops: list) -> list[str]:
	"""seal_problems only closes doored/`requires` links. An internal gate is checked here: shut,
	it must cut at least one exit off from at least one landing, or it blocks nothing — the
	open-box Span's gate did exactly that, walked round on either side."""
	out = []
	for name, slab in walls.gate_slabs(data):
		if not name.startswith("internal"):
			continue
		cuts = any(
			walls.reach(data, loops, roomlib.PLAYER, [slab], start)
			< walls.reach(data, loops, roomlib.PLAYER, [], start)
			for start in walls.starts(data)
		)
		if not cuts:
			out.append(f"{name} blocks nothing: every exit is reachable around it")
	return out


def check(data: dict, narrowest: bool = False) -> tuple[list[str], list[str]]:
	"""(errors, warnings) for one room dict."""
	notes = {n["id"] for n in json.loads((roomlib.ROOT / "data" / "notes.json").read_text())["notes"]}
	accepted = load_baseline().get(data.get("room_id", ""), [])
	errors, warnings = lint_room(data, accepted, notes)
	if errors:
		return errors, warnings
	loops = walls.wall_loops(data)
	errors += walls.loop_problems(loops) + walls.footprint_problems(data, loops)
	errors += walls.pin_problems(data, loops) + walls.seal_problems(data, loops)
	errors += internal_gate_problems(data, loops)
	if narrowest:
		warnings.append(f"narrowest passage {walls.narrowest(data, loops)} px (player {int(roomlib.PLAYER)})")
	return errors, warnings


def main(argv: list[str]) -> int:
	if not argv:
		print(__doc__.strip().splitlines()[-5])
		return 2
	room = argv[0] if argv[0].endswith(".json") else f"{argv[0]}.json"
	data = roomlib.load_room(roomlib.ROOMS_DIR / room)
	if "--grid" in argv:
		data = copy.deepcopy(data)
		path = argv[argv.index("--grid") + 1]
		data["grid"] = [line.rstrip("\n") for line in open(path) if line.strip()]
	errors, warnings = check(data, narrowest="--narrowest" in argv)
	for w in warnings:
		print(f"warning: {w}")
	for e in errors:
		print(f"error:   {e}", file=sys.stderr)
	print(f"check_room {data.get('room_id')}: " + (f"FAILED with {len(errors)} error(s)" if errors else "OK"))
	return 1 if errors else 0


if __name__ == "__main__":
	sys.exit(main(sys.argv[1:]))
