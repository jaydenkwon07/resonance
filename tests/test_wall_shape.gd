extends SceneTree
## Shape tests for the smooth-walls pipeline (M7) — the replacement for the 23 rock-bevel tests,
## retired with the bevel. No nodes, no scenes.
##
## Run:  godot --headless --script tests/test_wall_shape.gd
##
## test_wall_outline.gd proves the GDScript twin matches walls.py; this pins what the shape
## itself must do, concern for concern with the old bevel suite: corners are cut (and how
## much), all four corners alike, convex AND concave corners, an outcrop keeps a solid loop, an
## all-rock cell has no wall, and the collision is the drawn outline exactly.

const T := 30

var _passed := 0
var _failed := 0


func _initialize() -> void:
	test_corner_cut()
	test_passes_scale_the_cut()
	test_symmetric_corners()
	test_convex_and_concave()
	test_outcrops_and_interior()
	test_collision_is_the_outline()
	print("\n%d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


const BOX := ["########", "#......#", "#......#", "#......#", "#......#", "########"]


func _room(grid: Array) -> Dictionary:
	return {"room_id": "shape", "grid": grid}


## Traced corners are 45° cuts with half-tile legs, and straight walls stay straight.
func test_corner_cut() -> void:
	var loop := WallTrace.trace(BOX)[0]
	check(loop.size() == 8, "a box traces to an octagon: every corner is cut")
	var ok := true
	for k in loop.size():
		var d := loop[(k + 1) % loop.size()] - loop[k]
		if d.x != 0.0 and d.y != 0.0 and not (absf(d.x) == T / 2 and absf(d.y) == T / 2):
			ok = false
	check(ok, "every cut is 45° with half-tile legs; every other edge is axis-aligned")
	check(loop.has(Vector2(T + T / 2, T)) and loop.has(Vector2(T, T + T / 2)),
		"the top-left cut runs between cell-centre midpoints")
	var b := WallOutline.loops(_room(BOX), WallOutline.CHAIKIN_PASSES, 0.0)[0]
	var top := 0
	for p in b:
		top += 1 if p.y == float(T) and p.x > 2.0 * T and p.x < 6.0 * T else 0
	check(top >= 2, "corner cutting leaves the middle of a straight wall on its line")


## More Chaikin passes cut deeper and add vertices; zero passes is the raw trace.
func test_passes_scale_the_cut() -> void:
	var trace := WallTrace.trace(BOX)[0]
	var p0 := WallOutline.loops(_room(BOX), 0, 0.0)[0]
	var p1 := WallOutline.loops(_room(BOX), 1, 0.0)[0]
	var p2 := WallOutline.loops(_room(BOX), 2, 0.0)[0]
	check(p0 == trace, "zero passes is exactly the trace")
	check(p1.size() > p0.size() and p2.size() > p1.size(), "each pass adds vertices")
	var corner := Vector2(T + T / 2, T + T / 2)  # inside the top-left floor cell's centre
	check(_nearest(p2, corner) < _nearest(p0, corner), "passes pull the corner in toward the floor")
	check(not p1.has(Vector2(T + T / 2, T)), "one pass already cuts the traced corner vertex away")


## All four corners of a symmetric room cut alike (mirror images within a pixel of snapping).
func test_symmetric_corners() -> void:
	var b := WallOutline.loops(_room(BOX), WallOutline.CHAIKIN_PASSES, 0.0)[0]
	var w := float(BOX[0].length() * T)
	var h := float(BOX.size() * T)
	var mirror_x := true
	var mirror_y := true
	for p in b:
		mirror_x = mirror_x and _nearest(b, Vector2(w - p.x, p.y)) <= 1.5
		mirror_y = mirror_y and _nearest(b, Vector2(p.x, h - p.y)) <= 1.5
	check(mirror_x, "left and right corners are mirror images")
	check(mirror_y, "top and bottom corners are mirror images")


## Both an outer (convex) and an inner (concave) rock corner are cut — the bevel only cut
## convex ones by default.
func test_convex_and_concave() -> void:
	var ell := ["#######", "#.....#", "#.....#", "#..####", "#..####", "#######"]
	var loop := WallTrace.trace(ell)[0]
	# The inner corner of the L is the rock cell (3,3) with floor above, left and diagonal; its
	# cut joins the midpoints between those cell centres.
	check(loop.has(Vector2(3 * T + T / 2, 3 * T)) and loop.has(Vector2(3 * T, 3 * T + T / 2)),
		"a concave corner is cut at 45°")
	check(loop.has(Vector2(T + T / 2, T)) and loop.has(Vector2(T, T + T / 2)), "a convex corner is cut at 45°")
	check(WallOutline.signed_area(loop) < 0.0, "the L's outline keeps floor on the right (negative area)")
	check(Geometry2D.is_point_in_polygon(Vector2(1.5 * T, 1.5 * T), loop), "floor is inside the outline")


## An outcrop is its own solid loop at every stage, and all-rock has no wall at all.
func test_outcrops_and_interior() -> void:
	var lone := ["#######", "#.....#", "#.....#", "#..#..#", "#.....#", "#.....#", "#######"]
	var traced := WallTrace.trace(lone)
	check(traced.size() == 2, "a one-cell outcrop gets its own loop")
	var rock := traced[0] if WallOutline.signed_area(traced[0]) > 0.0 else traced[1]
	check(rock.size() == 4 and WallOutline.signed_area(rock) > 0.0, "a one-cell outcrop traces to a diamond, positive area")
	var c := WallOutline.loops(_room(lone))
	var solid := false
	for lp in c:
		if WallOutline.signed_area(lp) > 0.0:
			solid = lp.size() >= 3 and Geometry2D.is_point_in_polygon(Vector2(3.5 * T, 3.5 * T), lp)
	check(solid, "after cutting and roughness the one-cell outcrop is still solid at its centre")
	check(WallTrace.trace(["####", "####", "####"]).is_empty(), "all rock has no wall")
	check(WallTrace.trace(["....", "....", "...."]).size() == 1, "all floor is one outline, closed past the bounds")


## The collision and the occluder are the drawn outline itself: the same points, closed.
func test_collision_is_the_outline() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/rooms/room_hollow.json"))
	var loop := WallOutline.loops(data)[0]
	var segs := WallOutline.segments(loop)
	check(segs.size() == loop.size() * 2, "one collision segment per drawn edge")
	var same := true
	for k in loop.size():
		same = same and segs[2 * k] == loop[k] and segs[2 * k + 1] == loop[(k + 1) % loop.size()]
	check(same, "every collision segment is exactly a drawn edge, and the last closes the loop")
	var whole := true
	for p in loop:
		whole = whole and p.x == floorf(p.x) and p.y == floorf(p.y)
	check(whole, "outline vertices are whole native pixels")
	var w := float(str(data["grid"][0]).length() * T)
	var h := float((data["grid"] as Array).size() * T)
	var framed := true
	for p in loop:
		framed = framed and p.x >= -2.0 * T and p.y >= -2.0 * T and p.x <= w + 2.0 * T and p.y <= h + 2.0 * T
	check(framed, "outlines are in room coordinates, within the padded bounds")


func _nearest(loop: PackedVector2Array, p: Vector2) -> float:
	var best := INF
	for q in loop:
		best = minf(best, q.distance_to(p))
	return best


func check(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("  ok    " + label)
	else:
		_failed += 1
		print("  FAIL  " + label)
