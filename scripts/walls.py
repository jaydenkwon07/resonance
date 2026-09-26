#!/usr/bin/env python3
"""Smoothed wall outlines (M7 smooth-walls step) — the Python half of the pipeline.

A room grid becomes closed wall loops in five deterministic stages: trace → pin → corner-cut →
roughen → snap. The same loops are the wall's drawing, collision and light occluders in-game, so
this module and its GDScript twin must agree vertex for vertex. Everything that could differ
between the languages is pinned down here:

- integers only for hashing (32-bit masked FNV mixing, multipliers below 2^31 so GDScript's
  signed 64-bit ints never overflow);
- round-half-up snapping (`floor(v + 0.5)`), never Python's banker's `round()`;
- each loop starts at its smallest (y, x) vertex and loops are sorted, so no dict order leaks in;
- float maths in the same order on both sides (IEEE doubles agree when the operations do).

Stdlib only. Pinned zones come from `roomlib`, the one place the door/apron maths lives.
"""

from __future__ import annotations

import math

import roomlib
from roomlib import TILE

# --- Tuning (the spec's six constants; start values, tuned on the Hollow prototype) ---
CHAIKIN_PASSES = 2
CHAIKIN_RATIO = 0.25
ROUGH_STEP = 6.0      # px between roughness samples along a segment
ROUGH_AMP_MIN = 0.0   # px — lets some stretches stay clean
ROUGH_AMP_MAX = 2.0   # px — about 1/15 of a tile
ROUGH_SPAN = 120.0    # px of wall between amplitude samples (4 tiles)


_M32 = 0xFFFFFFFF

Point = tuple[float, float]
Loop = list[Point]


# --- Stage 1: trace ---

def _is_floor(grid: list[str], x: int, y: int) -> bool:
	"""Outside the grid is rock, except one cell straight out from a perimeter floor cell: an
	opening's corridor runs on past the bounds, so the trace keeps its walls straight through
	the edge band instead of cutting a corner into the mouth. Its loop closes off-camera."""
	h = len(grid)
	w = len(grid[0]) if h else 0
	if 0 <= y < h and 0 <= x < w:
		return grid[y][x] == "."
	if 0 <= y < h and x in (-1, w):
		return grid[y][0 if x < 0 else w - 1] == "."
	if 0 <= x < w and y in (-1, h):
		return grid[0 if y < 0 else h - 1][x] == "."
	return False


def trace(grid: list[str]) -> list[list[tuple[int, int]]]:
	"""Marching squares on the dual grid (cell centres, iso 0.5): the rock/floor boundary as
	closed integer-pixel loops, floor on the right when walking in screen space (y down). A
	saddle keeps the rock connected, so two floor cells touching only at a corner stay apart —
	the conservative choice for collision. Collinear vertices are merged; each loop starts at
	its smallest (y, x) vertex and loops are sorted, for parity with the GDScript twin."""
	h = len(grid)
	w = len(grid[0]) if h else 0
	half = TILE // 2
	nxt: dict[tuple[int, int], tuple[int, int]] = {}

	def centre(cx: int, cy: int) -> tuple[int, int]:
		return (cx * TILE + half, cy * TILE + half)

	for j in range(-2, h + 1):
		for i in range(-2, w + 1):
			# Dual cell corners: TL, TR, BR, BL cell centres.
			corners = [(i, j), (i + 1, j), (i + 1, j + 1), (i, j + 1)]
			f = [_is_floor(grid, cx, cy) for cx, cy in corners]
			if all(f) or not any(f):
				continue
			tl, tr, br, bl = (centre(*c) for c in corners)
			mid = {
				"T": ((tl[0] + tr[0]) // 2, tl[1]), "R": (tr[0], (tr[1] + br[1]) // 2),
				"B": ((bl[0] + br[0]) // 2, bl[1]), "L": (tl[0], (tl[1] + bl[1]) // 2),
			}
			pts = [tl, tr, br, bl]
			for a, b, floors in _segments(f):
				pa, pb = mid[a], mid[b]
				# Orient so the floor corners fall on the right of pa→pb (cross < 0, y down).
				fx = sum(pts[k][0] for k in floors) / len(floors)
				fy = sum(pts[k][1] for k in floors) / len(floors)
				cross = (pb[0] - pa[0]) * (fy - pa[1]) - (pb[1] - pa[1]) * (fx - pa[0])
				if cross > 0:
					pa, pb = pb, pa
				nxt[pa] = pb

	loops: list[list[tuple[int, int]]] = []
	while nxt:
		start = min(nxt, key=lambda p: (p[1], p[0]))
		loop = [start]
		p = nxt.pop(start)
		while p != start:
			loop.append(p)
			p = nxt.pop(p)
		loops.append(_canonical(_merge_collinear(loop)))
	loops.sort(key=lambda lp: (lp[0][1], lp[0][0]))
	return loops


def _segments(f: list[bool]) -> list[tuple[str, str, list[int]]]:
	"""Marching-squares edges for one dual cell: (from-edge, to-edge, floor corner indices on
	that segment's floor side). Corners 0..3 are TL, TR, BR, BL; edges T, R, B, L."""
	floors = [k for k in range(4) if f[k]]
	edges_of = {0: ("L", "T"), 1: ("T", "R"), 2: ("R", "B"), 3: ("B", "L")}
	if len(floors) == 1:
		a, b = edges_of[floors[0]]
		return [(a, b, floors)]
	if len(floors) == 3:
		rock = next(k for k in range(4) if not f[k])
		a, b = edges_of[rock]
		return [(a, b, floors)]
	# Two floor corners: adjacent → one straight segment; diagonal → saddle, rock connected.
	if f[0] and f[2] and not f[1]:
		return [("L", "T", [0]), ("R", "B", [2])]
	if f[1] and f[3] and not f[0]:
		return [("T", "R", [1]), ("B", "L", [3])]
	if f[0] and f[1]:
		return [("L", "R", floors)]
	if f[3] and f[2]:
		return [("L", "R", floors)]
	return [("T", "B", floors)]  # a left or right pair


def _merge_collinear(loop: list[tuple[int, int]]) -> list[tuple[int, int]]:
	out = list(loop)
	changed = True
	while changed and len(out) > 3:
		changed = False
		for k in range(len(out)):
			a, b, c = out[k - 1], out[k], out[(k + 1) % len(out)]
			if (b[0] - a[0]) * (c[1] - b[1]) - (b[1] - a[1]) * (c[0] - b[0]) == 0:
				del out[k]
				changed = True
				break
	return out


def _canonical(loop: list) -> list:
	k = min(range(len(loop)), key=lambda i: (loop[i][1], loop[i][0]))
	return loop[k:] + loop[:k]


def signed_area(loop: list) -> float:
	"""Shoelace area in screen space (y down), with trace()'s orientation: negative for the outer
	outline of a floor region, positive for an outcrop's loop (a hole in the floor)."""
	s = 0.0
	for k in range(len(loop)):
		x0, y0 = loop[k]
		x1, y1 = loop[(k + 1) % len(loop)]
		s += x0 * y1 - x1 * y0
	return s / 2.0


# --- Stage 2: pin ---

def pinned_cells(data: dict) -> set[tuple[int, int]]:
	"""Cells whose wall must not move: each exit's MOUTH (edge cell and landing cell, walls included, so
	the edge band and the mirrored landing hold), door footprints and approach clearance, and
	ability-gate zones — plus the cell straight out past the bounds from each pinned perimeter
	cell, where the trace carries an opening's corridor on (see _is_floor). Past the mouth an
	exit's walls smooth like any other (owner, Phase 1 round 1): exits needn't be a fixed
	straight corridor."""
	grid = data.get("grid", [])
	h = len(grid)
	w = len(grid[0]) if h else 0
	zone: set[tuple[int, int]] = set()
	for d in list(data.get("links", [])) + list(data.get("sealed_doors", [])):
		at = tuple(d.get("at", [0, 0]))
		inw = roomlib.inward(at, w, h)
		if inw == (0, 0):
			continue
		zone |= roomlib.mouth_cells(at, inw)
		if d.get("door") or d.get("requires") or "sockets" in d:
			zone |= roomlib.door_reserved_cells(at, inw)
	for g in data.get("ability_gates", []):
		cx, cy = roomlib.cell_center(*g["at"])
		slab = roomlib.rect_to_cells((cx - roomlib.SLAB_W * 0.5, cy - roomlib.SLAB_H * 0.5,
		                              cx + roomlib.SLAB_W * 0.5, cy + roomlib.SLAB_H * 0.5))
		fx, fy = g.get("facing", [0, 1])
		zone |= slab
		for c in slab:
			for k in (1, 2):
				zone.add((c[0] + fx * k, c[1] + fy * k))
				zone.add((c[0] - fx * k, c[1] - fy * k))
	for x, y in list(zone):
		if x == 0:
			zone.add((-1, y))
		if x == w - 1:
			zone.add((w, y))
		if y == 0:
			zone.add((x, -1))
		if y == h - 1:
			zone.add((x, h))
	return zone


def is_pinned(p: tuple[float, float], zone: set[tuple[int, int]]) -> bool:
	"""A vertex is pinned if any zone cell's closed rect contains it (vertices sit on cell
	boundaries, so a vertex on a zone's edge counts)."""
	x, y = p
	cx, cy = int(math.floor(x / TILE)), int(math.floor(y / TILE))
	xs = [cx - 1, cx] if x == cx * TILE else [cx]
	ys = [cy - 1, cy] if y == cy * TILE else [cy]
	return any((i, j) in zone for i in xs for j in ys)


# --- Stage 3: corner-cut ---

def chaikin(loop: list[Point], pins: list[bool], passes: int = CHAIKIN_PASSES,
            ratio: float = CHAIKIN_RATIO) -> tuple[list[Point], list[bool]]:
	"""Chaikin corner cutting that respects pins: a pinned vertex is kept as-is, a segment with
	both ends pinned is never cut, and where one end is pinned only the free end is cut."""
	for _ in range(passes):
		out: list[Point] = []
		out_pins: list[bool] = []
		n = len(loop)
		for k in range(n):
			a, b = loop[k], loop[(k + 1) % n]
			pa, pb = pins[k], pins[(k + 1) % n]
			if pa:
				out.append(a)
				out_pins.append(True)
			if pa and pb:
				continue
			if not pa:
				out.append((a[0] + (b[0] - a[0]) * ratio, a[1] + (b[1] - a[1]) * ratio))
				out_pins.append(False)
			if not pb:
				out.append((a[0] + (b[0] - a[0]) * (1.0 - ratio), a[1] + (b[1] - a[1]) * (1.0 - ratio)))
				out_pins.append(False)
		loop, pins = out, out_pins
	return loop, pins


# --- Stage 4: roughen ---

def hash32(*vals: int) -> int:
	"""FNV-1a over 32-bit words, then an avalanche. Integer-only so GDScript agrees exactly."""
	h = 2166136261
	for v in vals:
		h ^= v & _M32
		h = (h * 16777619) & _M32
	h ^= h >> 16
	h = (h * 0x7FEB352D) & _M32
	h ^= h >> 15
	h = (h * 0x297A2D39) & _M32
	h ^= h >> 16
	return h


def _unit(h: int) -> float:
	"""A hash to [0, 1]."""
	return float(h & 0xFFFF) / 65535.0


def roughen(loop: list[Point], pins: list[bool], seed: int, zone: set[tuple[int, int]],
            step: float = ROUGH_STEP, amp_min: float = ROUGH_AMP_MIN,
            amp_max: float = ROUGH_AMP_MAX, span: float = ROUGH_SPAN) -> list[Point]:
	"""Subdivide every segment that isn't pinned at both ends into ~`step` px pieces and push
	each interior point along the segment's normal by hash(point) × amplitude. The amplitude
	wanders along the wall: a second hash sampled every `span` px of arc length, interpolated,
	so some stretches stay smooth and some go rough. Segment endpoints never move, and neither
	does any point inside a pinned zone — a long straight wall may run on past its apron, and
	the part inside must stay exactly straight."""
	if amp_max <= 0.0:
		return list(loop)
	out: list[Point] = []
	n = len(loop)
	s = 0.0  # arc length walked so far
	for k in range(n):
		a, b = loop[k], loop[(k + 1) % n]
		out.append(a)
		dx, dy = b[0] - a[0], b[1] - a[1]
		length = math.sqrt(dx * dx + dy * dy)
		if length <= 0.0 or (pins[k] and pins[(k + 1) % n]):
			s += length
			continue
		pieces = max(1, int(math.floor(length / step + 0.5)))
		nx, ny = -dy / length, dx / length
		for i in range(1, pieces):
			t = float(i) / float(pieces)
			px, py = a[0] + dx * t, a[1] + dy * t
			if is_pinned((px, py), zone):
				out.append((px, py))
				continue
			arc = s + length * t
			slot = int(math.floor(arc / span))
			frac = arc / span - float(slot)
			a0 = amp_min + (amp_max - amp_min) * _unit(hash32(seed, slot, 1))
			a1 = amp_min + (amp_max - amp_min) * _unit(hash32(seed, slot + 1, 1))
			amp = a0 + (a1 - a0) * frac
			off = (_unit(hash32(seed, int(math.floor(px + 0.5)), int(math.floor(py + 0.5)))) * 2.0 - 1.0) * amp
			out.append((px + nx * off, py + ny * off))
		s += length
	return out


# --- Stage 5: snap ---

def snap(loop: list[Point]) -> list[tuple[int, int]]:
	"""Round to whole native pixels (half up), dropping consecutive duplicates."""
	out: list[tuple[int, int]] = []
	for x, y in loop:
		p = (int(math.floor(x + 0.5)), int(math.floor(y + 0.5)))
		if not out or out[-1] != p:
			out.append(p)
	while len(out) > 1 and out[0] == out[-1]:
		out.pop()
	return out


# --- The whole pipeline ---

def room_seed(room_id: str) -> int:
	"""A stable integer from the room id — FNV-1a over its UTF-8 bytes."""
	h = 2166136261
	for byte in room_id.encode("utf-8"):
		h ^= byte
		h = (h * 16777619) & _M32
	return h


def wall_loops(data: dict, passes: int = CHAIKIN_PASSES, amp_max: float = ROUGH_AMP_MAX) -> list[list[tuple[int, int]]]:
	"""A room's final wall loops, integer native pixels. `passes`/`amp_max` exist so captures
	and tests can render option B (amp_max 0) or the raw trace (passes 0) from one code path."""
	zone = pinned_cells(data)
	seed = room_seed(str(data.get("room_id", "")))
	out = []
	for index, traced in enumerate(trace(data.get("grid", []))):
		pts: list[Point] = [(float(x), float(y)) for x, y in traced]
		pins = [is_pinned(p, zone) for p in pts]
		pts, pins = chaikin(pts, pins, passes)
		pts = roughen(pts, pins, hash32(seed, index), zone, amp_max=amp_max)
		out.append(snap(pts))
	return out


# --- Checks on the final polygons (spec "Checks and tests") ---

def _seg_cross(p: tuple, q: tuple, r: tuple, s: tuple) -> bool:
	"""Do segments pq and rs properly intersect or touch? Integer-exact on snapped loops."""
	def orient(a, b, c) -> int:
		v = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
		return (v > 0) - (v < 0)

	def on(a, b, c) -> bool:
		return min(a[0], b[0]) <= c[0] <= max(a[0], b[0]) and min(a[1], b[1]) <= c[1] <= max(a[1], b[1])

	o1, o2, o3, o4 = orient(p, q, r), orient(p, q, s), orient(r, s, p), orient(r, s, q)
	if o1 != o2 and o3 != o4:
		return True
	return (o1 == 0 and on(p, q, r)) or (o2 == 0 and on(p, q, s)) or (o3 == 0 and on(r, s, p)) or (o4 == 0 and on(r, s, q))


def loop_problems(loops: list[list[tuple[int, int]]]) -> list[str]:
	"""Each loop closed (≥3 points) and simple, and no two loops touching. Segments are bucketed
	by tile so the pair test stays near-linear on big rooms."""
	out = []
	segs = []
	for li, lp in enumerate(loops):
		if len(lp) < 3:
			out.append(f"loop {li} has {len(lp)} points")
			continue
		for k in range(len(lp)):
			segs.append((li, k, lp[k], lp[(k + 1) % len(lp)], len(lp)))
	buckets: dict[tuple[int, int], list[int]] = {}
	for idx, (_, _, a, b, _) in enumerate(segs):
		for bx in range(min(a[0], b[0]) // TILE, max(a[0], b[0]) // TILE + 1):
			for by in range(min(a[1], b[1]) // TILE, max(a[1], b[1]) // TILE + 1):
				buckets.setdefault((bx, by), []).append(idx)
	seen: set[tuple[int, int]] = set()
	for ids in buckets.values():
		for i in range(len(ids)):
			for j in range(i + 1, len(ids)):
				a, b = sorted((ids[i], ids[j]))
				if (a, b) in seen:
					continue
				seen.add((a, b))
				la, ka, p, q, na = segs[a]
				lb, kb, r, s, _ = segs[b]
				if la == lb and ((ka + 1) % na == kb or (kb + 1) % na == ka):
					continue  # neighbours share an endpoint by construction
				if _seg_cross(p, q, r, s):
					out.append(f"loop {la} seg {ka} crosses loop {lb} seg {kb} near {p}")
	return out


def inside(p: tuple[float, float], loops: list[list[tuple[int, int]]]) -> bool:
	"""Is a point on floor? Even-odd over every loop (outer outline + outcrop holes)."""
	x, y = p
	c = False
	for lp in loops:
		for k in range(len(lp)):
			(x0, y0), (x1, y1) = lp[k], lp[(k + 1) % len(lp)]
			if (y0 > y) != (y1 > y) and x < x0 + (y - y0) * (x1 - x0) / (y1 - y0):
				c = not c
	return c


def footprint_problems(data: dict, loops: list[list[tuple[int, int]]]) -> list[str]:
	"""Every pickup, chime, prop and entry cell, and every door/gate footprint cell, must sit
	fully in floor: all four corners and the centre inside, and no wall vertex inside it."""
	cells: list[tuple[str, tuple[int, int]]] = []
	for key, label in (("pickups", "pickup"), ("chimes", "chime"), ("props", "prop")):
		for it in data.get(key, []):
			cells.append((label, tuple(it["at"])))
	for name, at in data.get("entries", {}).items():
		cells.append((f"entry {name}", tuple(at)))
	grid = data.get("grid", [])
	h = len(grid)
	w = len(grid[0]) if h else 0
	for d in list(data.get("links", [])) + list(data.get("sealed_doors", [])):
		if d.get("door") or d.get("requires") or "sockets" in d:
			at = tuple(d["at"])
			for c in roomlib.rect_to_cells(roomlib.door_rect(at, roomlib.inward(at, w, h))):
				# The slab overlaps the jamb rock by design; only its floor cells must stay floor.
				if 0 <= c[1] < h and 0 <= c[0] < w and grid[c[1]][c[0]] == ".":
					cells.append((f"door zone {at}", c))
	verts = {v for lp in loops for v in lp}
	out = []
	for label, (cx, cy) in cells:
		x0, y0 = cx * TILE, cy * TILE
		# Sample just inside the corners: a wall running exactly along a cell edge is fine.
		probes = [(x0 + 1, y0 + 1), (x0 + TILE - 1, y0 + 1), (x0 + 1, y0 + TILE - 1),
		          (x0 + TILE - 1, y0 + TILE - 1), (x0 + TILE / 2, y0 + TILE / 2)]
		if not all(inside(p, loops) for p in probes) or any(
			x0 < vx < x0 + TILE and y0 < vy < y0 + TILE for vx, vy in verts):
			out.append(f"{label} at {(cx, cy)} is crossed by a wall")
	return out


def pin_problems(data: dict, loops: list[list[tuple[int, int]]]) -> list[str]:
	"""Every pinned vertex of the trace survives, exactly, in the final loops."""
	zone = pinned_cells(data)
	final = {v for lp in loops for v in lp}
	return [f"pinned vertex {v} moved" for lp in trace(data.get("grid", []))
	        for v in lp if is_pinned(v, zone) and v not in final]


# --- Flood fill against the polygons: clearance and seals ---

def _box_hits_segment(bx0: float, by0: float, bx1: float, by1: float, a: tuple, b: tuple) -> bool:
	"""Does an axis-aligned box overlap segment ab? Liang–Barsky clip of the segment."""
	t0, t1 = 0.0, 1.0
	dx, dy = b[0] - a[0], b[1] - a[1]
	for p, q in ((-dx, a[0] - bx0), (dx, bx1 - a[0]), (-dy, a[1] - by0), (dy, by1 - a[1])):
		if p == 0:
			if q < 0:
				return False
		else:
			r = q / p
			if p < 0:
				t0 = max(t0, r)
			else:
				t1 = min(t1, r)
			if t0 > t1:
				return False
	return True


def starts(data: dict) -> list[tuple[float, float]]:
	"""Where the game puts a player in this room: each `from_*` entry at its link's derived landing
	(room.gd _record_entries — the authored cell can sit flush against a wall), any other entry
	at its cell centre."""
	grid = data["grid"]
	h, w = len(grid), len(grid[0])
	links = data.get("links", [])
	out = []
	for name, cell in data.get("entries", {}).items():
		if str(name).startswith("from_") and links:
			link = min(links, key=lambda l: math.dist(cell, l["at"]))
			at = tuple(link["at"])
			leaf = link.get("door") or link.get("requires")
			out.append(roomlib.inset_point(at, roomlib.inward(at, w, h),
			                               roomlib.DOOR_ENTRY_INSET if leaf else float(roomlib.ENTRY_INSET)))
		else:
			out.append(roomlib.cell_center(*cell))
	return out


def reach(data: dict, loops: list, box: float, slabs: list, start: tuple[float, float],
          step: float = 3.0) -> set[int]:
	"""Flood-fill a `box`-sized player centre from `start`; return the indices of the
	links whose edge band it can touch. `slabs` are extra blocking rects (closed doors/gates).
	The corridor extension past the bounds is walkable, so bands straddling the edge are reached
	the way the game reaches them."""
	grid = data["grid"]
	h, w = len(grid), len(grid[0])
	segs = [(lp[k], lp[(k + 1) % len(lp)]) for lp in loops for k in range(len(lp))]
	buckets: dict[tuple[int, int], list[int]] = {}
	for i, (a, b) in enumerate(segs):
		for bx in range(min(a[0], b[0]) // TILE, max(a[0], b[0]) // TILE + 1):
			for by in range(min(a[1], b[1]) // TILE, max(a[1], b[1]) // TILE + 1):
				buckets.setdefault((bx, by), []).append(i)
	bands = [roomlib.band_rect(tuple(l["at"]), roomlib.inward(tuple(l["at"]), w, h)) for l in data["links"]]
	half = box / 2.0

	def free(cx: float, cy: float) -> bool:
		x0, y0, x1, y1 = cx - half, cy - half, cx + half, cy + half
		if not inside((cx, cy), loops):
			return False
		for sx0, sy0, sx1, sy1 in slabs:
			if x0 < sx1 and x1 > sx0 and y0 < sy1 and y1 > sy0:
				return False
		near: set[int] = set()
		for bx in range(int(x0 // TILE), int(x1 // TILE) + 1):
			for by in range(int(y0 // TILE), int(y1 // TILE) + 1):
				near.update(buckets.get((bx, by), ()))
		return not any(_box_hits_segment(x0, y0, x1, y1, *segs[i]) for i in near)

	sx = round(start[0] / step) * step
	sy = round(start[1] / step) * step
	if not free(sx, sy):
		return set()
	seen = {(sx, sy)}
	todo = [(sx, sy)]
	hit: set[int] = set()
	while todo:
		cx, cy = todo.pop()
		for i, (x0, y0, x1, y1) in enumerate(bands):
			if cx - half < x1 and cx + half > x0 and cy - half < y1 and cy + half > y0:
				hit.add(i)
		for dx, dy in ((step, 0), (-step, 0), (0, step), (0, -step)):
			n = (cx + dx, cy + dy)
			if n not in seen and free(*n):
				seen.add(n)
				todo.append(n)
	return hit


def gate_slabs(data: dict) -> list[tuple[str, tuple]]:
	"""Every closable blocker: doored and `requires` links, and internal ability gates."""
	grid = data["grid"]
	h, w = len(grid), len(grid[0])
	out = []
	for l in data["links"]:
		if l.get("door") or l.get("requires"):
			at = tuple(l["at"])
			out.append((l.get("door") or f"gate {l['requires']['note']}", roomlib.door_rect(at, roomlib.inward(at, w, h))))
	for g in data.get("ability_gates", []):
		cx, cy = roomlib.cell_center(*g["at"])
		out.append((f"internal gate {g['note']}", (cx - roomlib.SLAB_W / 2, cy - roomlib.SLAB_H / 2,
		                                         cx + roomlib.SLAB_W / 2, cy + roomlib.SLAB_H / 2)))
	return out


def seal_problems(data: dict, loops: list) -> list[str]:
	"""seal_test on the polygons, from every place the game lands a player: with every gate open
	every exit is reachable, and closing a doored/`requires` link's own slab makes its exit
	unreachable."""
	out = []
	grid = data["grid"]
	h, w = len(grid), len(grid[0])
	for start in starts(data):
		everything = reach(data, loops, roomlib.PLAYER, [], start)
		for i, l in enumerate(data["links"]):
			if i not in everything:
				out.append(f"exit to {l['to_room']} unreachable from {start} with every gate open")
		for i, l in enumerate(data["links"]):
			if l.get("door") or l.get("requires"):
				at = tuple(l["at"])
				if i in reach(data, loops, roomlib.PLAYER, [roomlib.door_rect(at, roomlib.inward(at, w, h))], start):
					out.append(f"exit to {l['to_room']} still reachable from {start} with its gate shut (bypass)")
	return out


def narrowest(data: dict, loops: list) -> int:
	"""The widest square player (px) that still reaches every exit from every landing with every
	gate open — the room's narrowest passage, as the collision actually feels it."""
	need = set(range(len(data["links"])))
	lo, hi = 0, 90
	while lo < hi:
		mid = (lo + hi + 1) // 2
		if all(reach(data, loops, float(mid), [], st) >= need for st in starts(data)):
			lo = mid
		else:
			hi = mid - 1
	return lo
