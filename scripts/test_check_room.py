#!/usr/bin/env python3
"""Tests for check_room: the internal-gate check on the real Span, both ways. Run:

    python3 scripts/test_check_room.py
"""

from __future__ import annotations

import copy
import sys

import roomlib
import walls
from check_room import check, internal_gate_problems

SPAN = roomlib.load_room(roomlib.ROOMS_DIR / "room_span.json")

_passed = 0
_failed = 0


def expect(cond: bool, label: str) -> None:
	global _passed, _failed
	if cond:
		_passed += 1
		print(f"  ok    {label}")
	else:
		_failed += 1
		print(f"  FAIL  {label}")


def main() -> int:
	expect(internal_gate_problems(SPAN, walls.wall_loops(SPAN)) == [],
	       "the Span's gate cuts something off (the fissure makes it the only way across)")

	open_box = copy.deepcopy(SPAN)
	open_box["grid"] = [row.replace("v", ".") for row in open_box["grid"]]
	problems = internal_gate_problems(open_box, walls.wall_loops(open_box))
	expect(any("blocks nothing" in p for p in problems),
	       "with the fissure filled in, the gate is reported as blocking nothing")

	errors, _ = check(SPAN)
	expect(errors == [], "the real Span passes the whole check")

	print(f"{_passed} passed, {_failed} failed")
	return 1 if _failed else 0


if __name__ == "__main__":
	sys.exit(main())
