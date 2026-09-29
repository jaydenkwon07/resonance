class_name RoomCycle
extends RefCounted
## Pure cycling maths for World's debug room keys (F2/F3/F4). No nodes, no signals, no engine
## state — World passes in the ids from RoomGraph, so this stays testable under --script (the
## pure-seam discipline, CLAUDE.md §4).


## The id `delta` steps from `current` in `ids`, wrapping at both ends. An id not in the list
## counts as sitting just before the first, so +1 lands on the first and -1 on the last.
static func step(ids: Array, current: String, delta: int) -> String:
	if ids.is_empty():
		return ""
	var i := ids.find(current)
	if i == -1:
		return str(ids[0] if delta > 0 else ids[-1])
	return str(ids[posmod(i + delta, ids.size())])


## Where to land in a room with no entry named: `spawn` if authored, else the first entry. Not
## the room centre, which in a carved room is likely rock.
static func default_entry(entries: Array) -> String:
	if entries.is_empty():
		return ""
	return "spawn" if entries.has("spawn") else str(entries[0])
