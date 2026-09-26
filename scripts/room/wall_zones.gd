class_name WallZones
extends RefCounted
## Stage 2 of the smooth-walls pipeline (M7): the cells whose wall must not move. PURE, and the
## twin of `pinned_cells`/`is_pinned` in scripts/walls.py: each exit's mouth (edge cell + landing
## cell, flanking walls included), door footprints with their 2-tile approach, and internal ability-gate zones — plus the
## cell straight out past the bounds from each pinned perimeter cell, where the trace carries an
## opening's corridor on. Past the mouth an exit's walls smooth like any other (owner, round 1).
##
## Placement comes from RoomGeometry, so these zones sit exactly where doors and links do.

## Mirrors door.gd / ability_gate.gd `slab_size` (72 across × 90 deep in world axes) and
## roomlib.SLAB_W/H — this file can't read the node exports without breaking --script.
const SLAB := Vector2(72.0, 90.0)
## Mirrors roomlib.MOUTH_DEPTH / mouth_cells: cells from the edge an exit stays pinned — the
## perimeter cell and the landing cell, each across the two opening cells and the wall cell
## flanking either side, so the edge band and the mirrored landing never move.
const MOUTH_DEPTH := 2


## A set of pinned cells, as {Vector2i: true}.
static func pinned_cells(data: Dictionary) -> Dictionary:
	var grid: Array = data.get("grid", [])
	var h := grid.size()
	var w := str(grid[0]).length() if h > 0 else 0
	var geom := RoomGeometry.new(WallTrace.TILE, Vector2i(w, h))
	var zone := {}
	var openings: Array = data.get("links", []).duplicate()
	openings.append_array(data.get("sealed_doors", []))
	for d: Dictionary in openings:
		var at := RoomGeometry.to_v2i(d.get("at", [0, 0]))
		var inw := geom.inward(at)
		if inw == Vector2i.ZERO:
			continue
		var along := Vector2i(absi(inw.y), absi(inw.x))
		for m in range(-1, 3):  # the two opening cells plus the wall cell flanking each side
			for k in MOUTH_DEPTH:
				zone[at + along * m + inw * k] = true
		if _has_leaf(d):
			var centre := geom.inset_point(at, inw, RoomGeometry.DOOR_INSET)
			for c: Vector2i in _rect_cells(centre, SLAB):
				zone[c] = true
				for k in [1, 2]:
					zone[c + inw * k] = true
	for g: Dictionary in data.get("ability_gates", []):
		var cells := _rect_cells(geom.cell_center(RoomGeometry.to_v2i(g.get("at", [0, 0]))), SLAB)
		var facing := RoomGeometry.to_v2i(g.get("facing", [0, 1]))
		for c in cells:
			zone[c] = true
			for k in [1, 2]:
				zone[c + facing * k] = true
				zone[c - facing * k] = true
	for c: Vector2i in zone.keys():
		if c.x == 0:
			zone[Vector2i(-1, c.y)] = true
		if c.x == w - 1:
			zone[Vector2i(w, c.y)] = true
		if c.y == 0:
			zone[Vector2i(c.x, -1)] = true
		if c.y == h - 1:
			zone[Vector2i(c.x, h)] = true
	return zone


## A vertex is pinned if any zone cell's closed rect contains it — vertices sit on cell
## boundaries, so one on a zone's edge counts.
static func is_pinned(x: float, y: float, zone: Dictionary) -> bool:
	var t := float(WallTrace.TILE)
	var cx := floori(x / t)
	var cy := floori(y / t)
	var xs := [cx - 1, cx] if x == float(cx) * t else [cx]
	var ys := [cy - 1, cy] if y == float(cy) * t else [cy]
	for i: int in xs:
		for j: int in ys:
			if zone.has(Vector2i(i, j)):
				return true
	return false


## A doored link, a `requires` gate or a sealed door: anything with a leaf and its approach.
static func _has_leaf(d: Dictionary) -> bool:
	return not str(d.get("door", "")).is_empty() or not (d.get("requires", {}) as Dictionary).is_empty() \
		or d.has("sockets")


## Every tile a `size` rect centred on `centre` overlaps (roomlib.rect_to_cells).
static func _rect_cells(centre: Vector2, size: Vector2) -> Array[Vector2i]:
	var t := float(WallTrace.TILE)
	var x0 := float(centre.x) - float(size.x) * 0.5
	var y0 := float(centre.y) - float(size.y) * 0.5
	var out: Array[Vector2i] = []
	for cx in range(floori(x0 / t), ceili((x0 + float(size.x)) / t)):
		for cy in range(floori(y0 / t), ceili((y0 + float(size.y)) / t)):
			out.append(Vector2i(cx, cy))
	return out
