extends SceneTree
## Unit tests for the debug room/entry cycling maths. No nodes, no scenes.
##
## Run:  godot --headless --script tests/test_room_cycle.gd
##
## Targets RoomCycle, the pure seam behind World's F2/F3/F4 debug keys — NOT World, which
## references autoloads and can't compile under --script.

const IDS := ["room_hollow", "room_a", "room_b"]

var _passed := 0
var _failed := 0


func _initialize() -> void:
	test_step_forward_and_back()
	test_step_wraps()
	test_step_unknown_and_empty()
	test_default_entry()
	print("\n%d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func test_step_forward_and_back() -> void:
	check(RoomCycle.step(IDS, "room_a", 1) == "room_b", "next steps forward in order")
	check(RoomCycle.step(IDS, "room_a", -1) == "room_hollow", "previous steps back in order")


func test_step_wraps() -> void:
	check(RoomCycle.step(IDS, "room_b", 1) == "room_hollow", "next wraps from last to first")
	check(RoomCycle.step(IDS, "room_hollow", -1) == "room_b", "previous wraps from first to last")


func test_step_unknown_and_empty() -> void:
	check(RoomCycle.step(IDS, "nowhere", 1) == "room_hollow", "unknown current → next is the first")
	check(RoomCycle.step(IDS, "nowhere", -1) == "room_b", "unknown current → previous is the last")
	check(RoomCycle.step([], "room_a", 1) == "", "no rooms → empty id")
	check(RoomCycle.step(["solo"], "solo", 1) == "solo", "a single entry cycles to itself")


func test_default_entry() -> void:
	check(RoomCycle.default_entry(["from_a", "spawn"]) == "spawn", "spawn wins when authored")
	check(RoomCycle.default_entry(["from_a", "from_b"]) == "from_a", "otherwise the first entry")
	check(RoomCycle.default_entry([]) == "", "no entries → empty id")


func check(cond: bool, label: String) -> void:
	if cond:
		_passed += 1
		print("  ok    %s" % label)
	else:
		_failed += 1
		print("  FAIL  %s" % label)
