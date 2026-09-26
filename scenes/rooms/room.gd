class_name Room
extends Node2D
## A room built from data (§6.3, Fork B / D-M3-1). Reads its geometry from RoomGraph
## (data/rooms/<room_id>.json), builds its walls from the smoothed wall loops (RoomWalls, [M7]:
## drawing, collision and occluders from one outline), and instances the room's contents:
## transition links, note pickups, clue chimes, decorative props/sealed doors, and the doors
## that gate some links.
##
## [M6 Step 2a] The positional maths lives in the pure, unit-tested `RoomGeometry`, and content
## instancing in `RoomContent`, so this file stays orchestration + link wiring
## and stops growing every time a content type is added. Numbers are unchanged from M5 — the
## Cistern's LOCKED geometry is preserved.
##
## `transition_requested` is forwarded up from the room's RoomLinks so World can drive the room
## swap without being globally addressable (§6.2, §6.4).

signal transition_requested(to_room: String, to_entry: String)

## Which room this is. A thin per-room .tscn sets this; RoomGraph keys everything off it.
@export var room_id: String = ""

## The cave look (M5 Step 2b). Left null uses RockStyle's defaults; assign a .tres to retune
## floor/rock value gap, rim and grit without touching code.
@export var rock_style: RockStyle

# Tile size. 30px makes a 32×18 room exactly 960×540, so a one-screen room is a true fixed screen
# with no scroll (§5.2, §6.7, D-M3-5). The wall pipeline owns it (WallTrace.TILE, mirrored by
# roomlib.TILE for the Python tools), so walls and placement can't disagree.
var _tile_px: int = WallTrace.TILE
var _size: Vector2i = Vector2i.ZERO
var _entries: Dictionary = {}   # entry_id -> world-space Vector2 (tile centre)
var _geom: RoomGeometry


func _ready() -> void:
	var geo := RoomGraph.geometry(room_id)
	if geo.is_empty():
		push_error("Room '%s': no geometry." % room_id)
		return
	_size = RoomGeometry.to_v2i(geo.get("size_tiles", [0, 0]))
	RoomWalls.build(self, geo, _tile_px, rock_style)
	_geom = RoomGeometry.new(_tile_px, _size)
	RoomContent.build_props(self, _geom, geo.get("props", []))
	_record_entries(geo.get("entries", {}), geo.get("links", []))
	_build_links(geo.get("links", []))
	RoomContent.build_pickups(self, _geom, geo.get("pickups", []))
	RoomContent.build_chimes(self, _geom, geo.get("chimes", []))
	RoomContent.build_sealed_doors(self, _geom, geo.get("sealed_doors", []))
	RoomContent.build_ability_gates(self, _geom, geo.get("ability_gates", []))


## World-space extent, for the camera clamp (§6.2).
func bounds() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(_size) * float(_tile_px))


## World position of a named entry, or the room centre if the id is unknown.
func entry_position(entry_id: String) -> Vector2:
	return _entries.get(entry_id, bounds().get_center())


# --- Floor ---

## A stable per-cell floor variant so the same room always paints the same, but neighbouring cells
## differ: mostly one of the three base variants, occasionally the rare detail tile. A cheap
## spatial hash, not RNG — determinism matters (§5). Stays here (not in RoomGeometry) because it
## references RockAtlas's variant counts, which don't compile under --script. RoomWalls bakes the
## floor from it.
static func floor_variant(x: int, y: int) -> int:
	var h := absi((x * 73856093) ^ (y * 19349663))
	if h % 17 == 0:
		return RockAtlas.FLOOR_BASE_VARIANTS + (h % RockAtlas.FLOOR_DETAIL_VARIANTS)
	return h % RockAtlas.FLOOR_BASE_VARIANTS


# --- Entries and links ---

## A transition entry (`from_*`) lands just inside the destination's matching edge, centred on the
## opening — the mirror of the edge the player just left, so exiting one room's right lands at the
## next room's left at the same height (Undertale). Other entries (`spawn`) keep their authored
## position. A doored link lands the player room-side of the leaf, not in it (5a).
func _record_entries(entries: Dictionary, links: Array) -> void:
	for entry_id in entries:
		var cell := RoomGeometry.to_v2i(entries[entry_id])
		if str(entry_id).begins_with("from_"):
			var link := _nearest_link(links, cell)
			if not link.is_empty():
				var at := RoomGeometry.to_v2i(link.get("at", [0, 0]))
				var inward := _geom.inward(at)
				var has_leaf := not str(link.get("door", "")).is_empty() or not (link.get("requires", {}) as Dictionary).is_empty()
				var inset := RoomGeometry.DOOR_ENTRY_INSET if has_leaf else float(RoomGeometry.ENTRY_INSET)
				_entries[str(entry_id)] = _geom.inset_point(at, inward, inset)
				continue
		_entries[str(entry_id)] = _geom.cell_center(cell)


## The link whose opening a transition entry belongs to — the nearest one. The authored entry cell
## only has to point at the right opening; the exact landing spot is derived from that link's
## geometry.
func _nearest_link(links: Array, cell: Vector2i) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for link in links:
		var distance := Vector2(cell - RoomGeometry.to_v2i(link.get("at", [0, 0]))).length()
		if distance < best_distance:
			best_distance = distance
			best = link
	return best


func _build_links(links: Array) -> void:
	for link_def in links:
		var at := RoomGeometry.to_v2i(link_def.get("at", [0, 0]))
		var inward := _geom.inward(at)
		var link := RoomLink.new()
		link.to_room = str(link_def.get("to_room", ""))
		link.to_entry = str(link_def.get("to_entry", ""))
		# A thin band straddling the room boundary, spanning the opening: the player transitions on
		# reaching the very edge, not a tile early (Undertale). It reaches a little past the
		# boundary so a fast walker can't tunnel out.
		link.size = _geom.edge_band_size(inward)
		link.position = _geom.edge_band_position(at, inward)
		link.transition_requested.connect(_on_link_transition)
		add_child(link)

		var door_id := str(link_def.get("door", ""))
		if not door_id.is_empty():
			RoomContent.build_door(self, _geom, door_id, at, inward)
		else:
			var req: Dictionary = link_def.get("requires", {})
			var req_note := str(req.get("note", ""))
			if not req_note.is_empty():
				RoomContent.build_ability_gate(self, _geom, req_note, at, inward)


func _on_link_transition(to_room: String, to_entry: String) -> void:
	transition_requested.emit(to_room, to_entry)
