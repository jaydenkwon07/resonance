#!/usr/bin/env python3
"""Tests for the smoothed wall pipeline (M7 smooth-walls step), Python half.

    python3 scripts/test_walls.py

Exit non-zero on any failure. Stdlib only, no pytest (repo style). The GDScript parity test
lives beside RoomGeometry and compares against these loops.
"""

from __future__ import annotations

import math
import sys

import roomlib
import walls

_passed = 0
_failed = 0


def check(cond: bool, label: str) -> None:
	global _passed, _failed
	if cond:
		_passed += 1
		print(f"  ok    {label}")
	else:
		_failed += 1
		print(f"  FAIL  {label}")


def room(grid: list[str], links: list | None = None, **extra) -> dict:
	return {"room_id": "fixture", "geometry": "natural", "size_tiles": [len(grid[0]), len(grid)],
	        "grid": grid, "entries": {}, "links": links or [], "pickups": [], "chimes": [],
	        "props": [], **extra}


def dist_to_polyline(p, loop) -> float:
	best = math.inf
	for k in range(len(loop)):
		(ax, ay), (bx, by) = loop[k], loop[(k + 1) % len(loop)]
		dx, dy = bx - ax, by - ay
		t = 0.0 if dx == dy == 0 else max(0.0, min(1.0, ((p[0] - ax) * dx + (p[1] - ay) * dy) / (dx * dx + dy * dy)))
		best = min(best, math.hypot(p[0] - ax - dx * t, p[1] - ay - dy * t))
	return best


def main() -> int:
	box = ["########", "#......#", "#......#", "#......#", "#......#", "########"]

	# Trace: a plain box gives one loop on the cell-centre contour, corners cut at 45°.
	loops = walls.trace(box)
	check(len(loops) == 1 and len(loops[0]) == 8, "a box traces to one octagon")
	check(walls.signed_area(loops[0]) < 0, "an outer floor outline has negative area")

	# Outcrops: an interior rock island gets its own loop (a hole), with collision like any wall.
	pillar = list(box); pillar[2] = pillar[3] = "#..##..#"
	loops = walls.trace(pillar)
	check(len(loops) == 2 and sum(walls.signed_area(lp) > 0 for lp in loops) == 1,
		"an interior outcrop produces its own loop")
	final = walls.wall_loops(room(pillar))
	check(len(final) == 2 and not walls.inside((4 * 30, 3 * 30), final)
		and walls.inside((1 * 30 + 15, 1 * 30 + 15), final), "the outcrop is solid, the floor is not")

	# Saddle: two floor cells touching only at a corner stay apart (rock connects).
	saddle = ["####", "#.##", "##.#", "####"]
	check(len(walls.trace(saddle)) == 2, "a diagonal floor pair traces as two loops (rock connected)")

	# Determinism: the same grid gives identical loops on two runs.
	hollow = roomlib.load_room(roomlib.ROOMS_DIR / "room_hollow.json")
	check(walls.wall_loops(hollow) == walls.wall_loops(hollow), "the same grid gives identical loops")

	# Pinning: an apron keeps its straight edges and exact vertices.
	apron = ["##########", "##########", "#.........", "#.........", "#........#", "##########"]
	r = room(apron, links=[{"at": [9, 2], "to_room": "x", "to_entry": "y"}])
	traced = walls.trace(apron)[0]
	final = walls.wall_loops(r)[0]
	pinned = [v for v in traced if walls.is_pinned(v, walls.pinned_cells(r))]
	check(pinned and all(v in final for v in pinned), "an apron's pinned vertices survive exactly")
	check(walls.pin_problems(r, walls.wall_loops(r)) == [], "pin check passes on the apron fixture")
	edge = [v for v in final if v[0] >= 5 * 30 and v[1] in (60, 120)]
	check(len({v[1] for v in edge}) == 2, "the apron's walls stay on their straight lines")

	# Pinning: a door fixture keeps its footprint clear of wall. Built like a real door: a 2-wide
	# opening cut through a 2-thick wall, so the leaf's floor cells are corridor, not a corner.
	door = ["############", "############", "##........##", "##........##", "##..........",
	        "##..........", "##........##", "##........##", "############"]
	r = room(door, links=[{"at": [11, 4], "to_room": "x", "to_entry": "y", "door": "d"}])
	check(walls.footprint_problems(r, walls.wall_loops(r)) == [], "a door's footprint stays clear of wall")

	# Stages: B moves no point further than the corner cut allows; C no more than AMP_MAX from B.
	b = walls.wall_loops(hollow, amp_max=0)
	c = walls.wall_loops(hollow)
	t = walls.trace(hollow["grid"])
	longest = max(math.dist(lp[k], lp[(k + 1) % len(lp)]) for lp in t for k in range(len(lp)))
	check(all(dist_to_polyline(p, t[0]) <= walls.CHAIKIN_RATIO * longest + 1 for p in b[0]),
		"B stays within the corner-cut bound of the trace")
	snap = math.sqrt(2)  # both B and C are snapped to whole pixels
	check(all(dist_to_polyline(p, b[0]) <= walls.ROUGH_AMP_MAX + snap for p in c[0]),
		"C moves no point more than ROUGH_AMP_MAX (+ snapping) from B")
	check(len(c[0]) > len(b[0]), "roughness subdivides the walls")

	# Snap: every final vertex is a whole native pixel, no consecutive duplicates.
	check(all(isinstance(x, int) and isinstance(y, int) for lp in c for x, y in lp)
		and all(lp[k] != lp[(k + 1) % len(lp)] for lp in c for k in range(len(lp))), "loops are snapped and deduplicated")

	# Hash: integer-only and stable (a GDScript twin must reproduce these exact values).
	check(walls.hash32(1, 2, 3) == walls.hash32(1, 2, 3) and walls.hash32(1, 2, 3) != walls.hash32(3, 2, 1),
		"hash32 is stable and order-sensitive")
	check(walls.hash32(-1) == walls.hash32(0xFFFFFFFF), "hash32 treats ints as 32-bit words")

	# Every real room: valid loops, content and door zones in floor, pins held.
	for path in sorted(roomlib.ROOMS_DIR.glob("*.json")):
		d = roomlib.load_room(path)
		lp = walls.wall_loops(d)
		probs = walls.loop_problems(lp) + walls.footprint_problems(d, lp) + walls.pin_problems(d, lp)
		check(probs == [], f"{path.stem}: loops valid, footprints clear, pins held"
			+ ("" if not probs else f" — {probs[:3]}"))

	# Parity: the fixture the GDScript twin is checked against must be what walls.py makes now.
	import export_wall_loops
	current = export_wall_loops.OUT.exists() and export_wall_loops.OUT.read_text(encoding="utf-8") \
		== export_wall_loops.render(export_wall_loops.export())
	check(current, "tests/fixtures/wall_loops.json is current (else run scripts/export_wall_loops.py)")

	print(f"\n{_passed} passed, {_failed} failed")
	return 1 if _failed else 0


if __name__ == "__main__":
	sys.exit(main())
