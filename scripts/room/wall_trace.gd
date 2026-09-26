class_name WallTrace
extends RefCounted
## Stage 1 of the smooth-walls pipeline (M7): the rock/floor boundary of a room grid as closed
## integer-pixel loops. PURE — no nodes, no autoloads — and the exact twin of `trace()` in
## scripts/walls.py; tests/test_wall_outline.gd holds the two to vertex-for-vertex parity, so
## change both or neither.
##
## Marching squares on the dual grid (cell centres, iso 0.5), floor on the right when walking in
## screen space (y down): outer floor outlines have negative shoelace area, outcrop loops
## positive. A saddle keeps the rock connected. Collinear vertices are merged; each loop starts
## at its smallest (y, x) vertex and loops are sorted, so no dictionary order leaks in.

const TILE := 30

# Dual-cell edge ids, and which two edges each floor-corner case joins (corners TL TR BR BL).
const _T := 0
const _R := 1
const _B := 2
const _L := 3
const _EDGES_OF := [[_L, _T], [_T, _R], [_R, _B], [_B, _L]]


## Outside the grid is rock, except one cell straight out from a perimeter floor cell: an
## opening's corridor runs on past the bounds, so the mouth isn't narrowed by a cut corner. Its
## loop closes off-camera.
static func is_floor(grid: Array, x: int, y: int) -> bool:
	var h := grid.size()
	var w := str(grid[0]).length() if h > 0 else 0
	if y >= 0 and y < h and x >= 0 and x < w:
		return str(grid[y])[x] == "."
	if y >= 0 and y < h and (x == -1 or x == w):
		return str(grid[y])[0 if x < 0 else w - 1] == "."
	if x >= 0 and x < w and (y == -1 or y == h):
		return str(grid[0 if y < 0 else h - 1])[x] == "."
	return false


static func trace(grid: Array) -> Array[PackedVector2Array]:
	var h := grid.size()
	var w := str(grid[0]).length() if h > 0 else 0
	var nxt := {}  # Vector2i -> Vector2i
	for j in range(-2, h + 1):
		for i in range(-2, w + 1):
			var f: Array[bool] = [is_floor(grid, i, j), is_floor(grid, i + 1, j),
				is_floor(grid, i + 1, j + 1), is_floor(grid, i, j + 1)]
			if not (f.has(true) and f.has(false)):
				continue
			var pts: Array[Vector2i] = [_centre(i, j), _centre(i + 1, j), _centre(i + 1, j + 1), _centre(i, j + 1)]
			var mid: Array[Vector2i] = [
				Vector2i((pts[0].x + pts[1].x) / 2, pts[0].y), Vector2i(pts[1].x, (pts[1].y + pts[2].y) / 2),
				Vector2i((pts[3].x + pts[2].x) / 2, pts[3].y), Vector2i(pts[0].x, (pts[0].y + pts[3].y) / 2),
			]
			for seg in _segments(f):
				var pa := mid[seg[0]]
				var pb := mid[seg[1]]
				var floors: Array = seg[2]
				# Orient so the floor corners fall on the right of pa→pb (cross < 0, y down).
				var fx := 0.0
				var fy := 0.0
				for k in floors:
					fx += float(pts[k].x)
					fy += float(pts[k].y)
				fx /= float(floors.size())
				fy /= float(floors.size())
				var cross := float(pb.x - pa.x) * (fy - float(pa.y)) - float(pb.y - pa.y) * (fx - float(pa.x))
				if cross > 0.0:
					var t := pa
					pa = pb
					pb = t
				nxt[pa] = pb

	var loops: Array[PackedVector2Array] = []
	while not nxt.is_empty():
		var start: Vector2i = nxt.keys()[0]
		for p: Vector2i in nxt:
			if p.y < start.y or (p.y == start.y and p.x < start.x):
				start = p
		var loop: Array[Vector2i] = [start]
		var p: Vector2i = nxt[start]
		nxt.erase(start)
		while p != start:
			loop.append(p)
			var q: Vector2i = nxt[p]
			nxt.erase(p)
			p = q
		loops.append(_canonical(_merge_collinear(loop)))
	loops.sort_custom(func(a: PackedVector2Array, b: PackedVector2Array) -> bool:
		return a[0].y < b[0].y or (a[0].y == b[0].y and a[0].x < b[0].x))
	return loops


static func _centre(cx: int, cy: int) -> Vector2i:
	return Vector2i(cx * TILE + TILE / 2, cy * TILE + TILE / 2)


## Marching-squares edges for one dual cell: [from-edge, to-edge, floor corner indices on that
## segment's floor side].
static func _segments(f: Array[bool]) -> Array:
	var floors: Array[int] = []
	for k in 4:
		if f[k]:
			floors.append(k)
	if floors.size() == 1:
		return [[_EDGES_OF[floors[0]][0], _EDGES_OF[floors[0]][1], floors]]
	if floors.size() == 3:
		var rock := f.find(false)
		return [[_EDGES_OF[rock][0], _EDGES_OF[rock][1], floors]]
	# Two floor corners: adjacent → one straight segment; diagonal → saddle, rock connected.
	if f[0] and f[2] and not f[1]:
		return [[_L, _T, [0]], [_R, _B, [2]]]
	if f[1] and f[3] and not f[0]:
		return [[_T, _R, [1]], [_B, _L, [3]]]
	if (f[0] and f[1]) or (f[3] and f[2]):
		return [[_L, _R, floors]]
	return [[_T, _B, floors]]  # a left or right pair


## Drop vertices collinear with their neighbours, one at a time from the front, as walls.py does.
static func _merge_collinear(loop: Array[Vector2i]) -> Array[Vector2i]:
	var out := loop.duplicate()
	var changed := true
	while changed and out.size() > 3:
		changed = false
		for k in out.size():
			var a: Vector2i = out[k - 1] if k > 0 else out[out.size() - 1]
			var b: Vector2i = out[k]
			var c: Vector2i = out[(k + 1) % out.size()]
			if (b.x - a.x) * (c.y - b.y) - (b.y - a.y) * (c.x - b.x) == 0:
				out.remove_at(k)
				changed = true
				break
	return out


static func _canonical(loop: Array[Vector2i]) -> PackedVector2Array:
	var k := 0
	for i in loop.size():
		if loop[i].y < loop[k].y or (loop[i].y == loop[k].y and loop[i].x < loop[k].x):
			k = i
	var out := PackedVector2Array()
	for i in loop.size():
		out.append(Vector2(loop[(k + i) % loop.size()]))
	return out
