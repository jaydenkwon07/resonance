extends SceneTree
## Parity + behaviour tests for the smooth-walls pipeline (M7): WallTrace, WallZones and
## WallOutline against loops exported from scripts/walls.py. No nodes, no scenes.
##
## Run:  godot --headless --script tests/test_wall_outline.gd
##
## The fixture (tests/fixtures/wall_loops.json) is written by scripts/export_wall_loops.py, and
## test_walls.py fails if it is stale. Every case — six fixture grids and all eleven rooms — is
## compared vertex for vertex at three stages: the raw trace, option B (no roughness) and
## option C (start values). A mismatch means the two languages drew different walls.

const FIXTURE := "res://tests/fixtures/wall_loops.json"

var _passed := 0
var _failed := 0


func _initialize() -> void:
	var doc: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	test_hash(doc)
	test_parity(doc)
	test_determinism()
	test_outcrop_and_orientation()
	test_segments_share_the_loop()
	print("\n%d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func test_hash(doc: Dictionary) -> void:
	for row: Array in doc["hashes"]:
		var vals: Array = []
		for v: float in row[0]:
			vals.append(int(v))
		check(WallOutline.hash32(vals) == int(row[1]), "hash32%s matches walls.py" % [vals])
	var seeds: Dictionary = doc["seeds"]
	for case: Dictionary in doc["cases"]:
		var id := str(_data(case).get("room_id", ""))
		check(WallOutline.room_seed(id) == int(seeds[case["name"]]), "room_seed(%s) matches walls.py" % id)


func test_parity(doc: Dictionary) -> void:
	for case: Dictionary in doc["cases"]:
		var data := _data(case)
		var name: String = case["name"]
		_same(WallTrace.trace(data.get("grid", [])), case["trace"], name + ": trace matches")
		_same(WallOutline.loops(data, WallOutline.CHAIKIN_PASSES, 0.0), case["b"], name + ": B matches")
		_same(WallOutline.loops(data), case["c"], name + ": C matches")


func test_determinism() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/rooms/room_hollow.json"))
	check(WallOutline.loops(data) == WallOutline.loops(data), "the same grid gives identical loops")


func test_outcrop_and_orientation() -> void:
	var grid := ["########", "#......#", "#..##..#", "#..##..#", "#......#", "########"]
	var loops := WallOutline.loops({"room_id": "t", "grid": grid})
	check(loops.size() == 2, "an interior outcrop produces its own loop")
	var neg := 0
	for lp in loops:
		neg += 1 if WallOutline.signed_area(lp) < 0.0 else 0
	check(neg == 1, "one outer floor outline (negative area) and one outcrop (positive)")


## One source: the collision segments are exactly the drawn loop's edges, closed.
func test_segments_share_the_loop() -> void:
	var loop := PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(10, 10)])
	var segs := WallOutline.segments(loop)
	check(segs.size() == 6 and segs[0] == loop[0] and segs[1] == loop[1] and segs[4] == loop[2]
		and segs[5] == loop[0], "segments walk the loop and close it")


func _data(case: Dictionary) -> Dictionary:
	if case.has("room"):
		return JSON.parse_string(FileAccess.get_file_as_string(case["room"]))
	return case["data"]


func _same(got: Array[PackedVector2Array], want: Array, label: String) -> void:
	var ok := got.size() == want.size()
	var where := "loop count %d vs %d" % [got.size(), want.size()]
	for i in mini(got.size(), want.size()):
		if not ok:
			break
		var w: Array = want[i]
		if got[i].size() != w.size():
			ok = false
			where = "loop %d: %d vs %d vertices" % [i, got[i].size(), w.size()]
			break
		for k in w.size():
			if got[i][k] != Vector2(float(w[k][0]), float(w[k][1])):
				ok = false
				where = "loop %d vertex %d: %s vs %s" % [i, k, got[i][k], w[k]]
				break
	check(ok, label + ("" if ok else " — " + where))


func check(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("  ok    " + label)
	else:
		_failed += 1
		print("  FAIL  " + label)
