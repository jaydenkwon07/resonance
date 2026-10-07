#!/usr/bin/env python3
"""Write tests/fixtures/wall_loops.json — the Python side of the smooth-walls parity test.

    python3 scripts/export_wall_loops.py

tests/test_wall_outline.gd rebuilds every case with the GDScript twin (WallOutline) and compares
vertex for vertex; test_walls.py fails if this file is stale. Re-run after any change to
walls.py, a room grid or the pinned zones.
"""

from __future__ import annotations

import json
import sys

import roomlib
import walls

OUT = roomlib.ROOT / "tests" / "fixtures" / "wall_loops.json"


def fixture(name: str, grid: list[str], links: list | None = None, **extra) -> dict:
	data = {"room_id": name, "geometry": "natural", "size_tiles": [len(grid[0]), len(grid)],
	        "grid": grid, "entries": {}, "links": links or [], **extra}
	return {"name": name, "data": data}


FIXTURES = [
	fixture("box", ["########", "#......#", "#......#", "#......#", "#......#", "########"]),
	fixture("pillar", ["########", "#......#", "#..##..#", "#..##..#", "#......#", "########"]),
	fixture("saddle", ["####", "#.##", "##.#", "####"]),
	fixture("apron", ["##########", "##########", "#.........", "#.........", "#........#", "##########"],
	        [{"at": [9, 2], "to_room": "x", "to_entry": "y"}]),
	fixture("door", ["############", "############", "##........##", "##........##", "##..........",
	                 "##..........", "##........##", "##........##", "############"],
	        [{"at": [11, 4], "to_room": "x", "to_entry": "y", "door": "d"}]),
	fixture("gate", ["##########", "#........#", "#........#", "#........#", "#........#", "##########"],
	        ability_gates=[{"at": [4, 2], "note": "n", "facing": [1, 0]}]),
	fixture("inner_door", ["############", "#..........#", "#..........#", "#......##..#", "#......#...#",
	                       "#......#...#", "#......##..#", "#..........#", "############"],
	        sealed_doors=[{"at": [7, 4], "facing": [-1, 0], "sockets": 0}]),
]

HASHES = [[1, 2, 3], [3, 2, 1], [-1], [0], [2166136261, 7, -30], [123456789, 42, 1]]


def export() -> dict:
	cases = list(FIXTURES)
	for path in sorted(roomlib.ROOMS_DIR.glob("*.json")):
		cases.append({"name": path.stem, "room": f"res://data/rooms/{path.name}", "data": roomlib.load_room(path)})
	out = []
	for case in cases:
		d = case["data"]
		entry = {"name": case["name"]}
		if "room" in case:
			entry["room"] = case["room"]
		else:
			entry["data"] = d
		entry["trace"] = walls.trace(d["grid"])
		entry["b"] = walls.wall_loops(d, amp_max=0)
		entry["c"] = walls.wall_loops(d)
		out.append(entry)
	return {
		"hashes": [[v, walls.hash32(*v)] for v in HASHES],
		"seeds": {case["name"]: walls.room_seed(case["data"]["room_id"]) for case in cases},
		"cases": out,
	}


def render(doc: dict) -> str:
	return json.dumps(doc, separators=(",", ":")) + "\n"


def main() -> int:
	OUT.parent.mkdir(parents=True, exist_ok=True)
	OUT.write_text(render(export()), encoding="utf-8")
	print(f"wrote {OUT.relative_to(roomlib.ROOT)}")
	return 0


if __name__ == "__main__":
	sys.exit(main())
