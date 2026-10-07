class_name WallOutline
extends RefCounted
## The smooth-walls pipeline (M7): a room grid becomes closed wall loops in five deterministic
## stages — trace (WallTrace) → pin (WallZones) → corner-cut → roughen → snap. The final loops
## are the wall's drawing, collision AND light occluders (RoomWalls builds all three from one
## vertex list), so what looks solid is solid.
##
## PURE — no nodes, no autoloads — and the exact twin of scripts/walls.py. Parity is held vertex
## for vertex by tests/test_wall_outline.gd against loops exported from Python, so anything that
## could differ between the languages is pinned: integer-only hashing (32-bit masked, multipliers
## below 2^31 so GDScript's signed 64-bit ints never overflow), round-half-up snapping, and float
## maths done in doubles (never Vector2, which is float32) in the same order as walls.py.

# --- Tuning: the spec's six constants, in one place (walls.py holds the same six) ---
const CHAIKIN_PASSES := 2
const CARVED_CHAIKIN_PASSES := 1  ## carved rooms keep their built corners (owner, 2026-10-06)
const CHAIKIN_RATIO := 0.25
const ROUGH_STEP := 6.0      ## px between roughness samples along a segment
const ROUGH_AMP_MIN := 0.0   ## px — lets some stretches stay clean
const ROUGH_AMP_MAX := 2.0   ## px — about 1/15 of a tile
const ROUGH_SPAN := 120.0    ## px of wall between amplitude samples (4 tiles)

const _M32 := 0xFFFFFFFF


## Corner-cutting passes for a room: fewer for carved rooms, which should read as built.
static func passes_for(data: Dictionary) -> int:
	return CARVED_CHAIKIN_PASSES if data.get("geometry") == "carved" else CHAIKIN_PASSES


## A room's final wall loops, whole native pixels. `passes`/`amp_max` let a capture render
## option B (amp_max 0) or the raw trace (passes 0) through the same code path; a negative
## `passes` means the room's own (`passes_for`).
static func loops(data: Dictionary, passes: int = -1, amp_max: float = ROUGH_AMP_MAX) -> Array[PackedVector2Array]:
	if passes < 0:
		passes = passes_for(data)
	var zone := WallZones.pinned_cells(data)
	var seed := room_seed(str(data.get("room_id", "")))
	var out: Array[PackedVector2Array] = []
	var traced := WallTrace.trace(data.get("grid", []))
	for index in traced.size():
		var xs := PackedFloat64Array()
		var ys := PackedFloat64Array()
		var pins: Array[bool] = []
		for v in traced[index]:
			xs.append(v.x)
			ys.append(v.y)
			pins.append(WallZones.is_pinned(v.x, v.y, zone))
		for _pass in passes:
			_chaikin(xs, ys, pins, CHAIKIN_RATIO)
		if amp_max > 0.0:
			_roughen(xs, ys, pins, hash32([seed, index]), zone, amp_max)
		out.append(_snap(xs, ys))
	return out


## Shoelace area in screen space (y down): negative for a floor region's outline, positive for
## an outcrop's loop.
static func signed_area(loop: PackedVector2Array) -> float:
	var s := 0.0
	for k in loop.size():
		var a := loop[k]
		var b := loop[(k + 1) % loop.size()]
		s += a.x * b.y - b.x * a.y
	return s / 2.0


## A closed loop as explicit segment pairs (a0 b0 a1 b1 …) — the collision shape's input.
static func segments(loop: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in loop.size():
		out.append(loop[k])
		out.append(loop[(k + 1) % loop.size()])
	return out


## FNV-1a over 32-bit words, then an avalanche. Integer-only so walls.py agrees exactly.
static func hash32(vals: Array) -> int:
	var h := 2166136261
	for v: int in vals:
		h ^= v & _M32
		h = (h * 16777619) & _M32
	h ^= h >> 16
	h = (h * 0x7FEB352D) & _M32
	h ^= h >> 15
	h = (h * 0x297A2D39) & _M32
	h ^= h >> 16
	return h


## A stable integer from the room id — FNV-1a over its UTF-8 bytes.
static func room_seed(room_id: String) -> int:
	var h := 2166136261
	for byte in room_id.to_utf8_buffer():
		h ^= byte
		h = (h * 16777619) & _M32
	return h


static func _unit(h: int) -> float:
	return float(h & 0xFFFF) / 65535.0


## One Chaikin pass that respects pins, in place: a pinned vertex is kept, a segment with both
## ends pinned is never cut, and where one end is pinned only the free end is cut.
static func _chaikin(xs: PackedFloat64Array, ys: PackedFloat64Array, pins: Array[bool], ratio: float) -> void:
	var ox := PackedFloat64Array()
	var oy := PackedFloat64Array()
	var op: Array[bool] = []
	var n := xs.size()
	for k in n:
		var m := (k + 1) % n
		var ax := xs[k]
		var ay := ys[k]
		var bx := xs[m]
		var by := ys[m]
		if pins[k]:
			ox.append(ax); oy.append(ay); op.append(true)
		if pins[k] and pins[m]:
			continue
		if not pins[k]:
			ox.append(ax + (bx - ax) * ratio); oy.append(ay + (by - ay) * ratio); op.append(false)
		if not pins[m]:
			ox.append(ax + (bx - ax) * (1.0 - ratio)); oy.append(ay + (by - ay) * (1.0 - ratio)); op.append(false)
	xs.clear(); xs.append_array(ox)
	ys.clear(); ys.append_array(oy)
	pins.assign(op)


## Subdivide every segment not pinned at both ends into ~ROUGH_STEP px pieces and push each
## interior point along the segment's normal by hash(point) × amplitude. The amplitude wanders
## along the wall (a second hash every ROUGH_SPAN px of arc, interpolated), so some stretches
## stay smooth and some go rough. Endpoints never move, nor does any point in a pinned zone.
static func _roughen(xs: PackedFloat64Array, ys: PackedFloat64Array, pins: Array[bool], seed: int,
		zone: Dictionary, amp_max: float) -> void:
	var ox := PackedFloat64Array()
	var oy := PackedFloat64Array()
	var n := xs.size()
	var s := 0.0  # arc length walked so far
	for k in n:
		var m := (k + 1) % n
		var ax := xs[k]
		var ay := ys[k]
		ox.append(ax); oy.append(ay)
		var dx := xs[m] - ax
		var dy := ys[m] - ay
		var length := sqrt(dx * dx + dy * dy)
		if length <= 0.0 or (pins[k] and pins[m]):
			s += length
			continue
		var pieces := maxi(1, floori(length / ROUGH_STEP + 0.5))
		var nx := -dy / length
		var ny := dx / length
		for i in range(1, pieces):
			var t := float(i) / float(pieces)
			var px := ax + dx * t
			var py := ay + dy * t
			if WallZones.is_pinned(px, py, zone):
				ox.append(px); oy.append(py)
				continue
			var arc := s + length * t
			var slot := floori(arc / ROUGH_SPAN)
			var frac := arc / ROUGH_SPAN - float(slot)
			var a0 := ROUGH_AMP_MIN + (amp_max - ROUGH_AMP_MIN) * _unit(hash32([seed, slot, 1]))
			var a1 := ROUGH_AMP_MIN + (amp_max - ROUGH_AMP_MIN) * _unit(hash32([seed, slot + 1, 1]))
			var amp := a0 + (a1 - a0) * frac
			var off := (_unit(hash32([seed, floori(px + 0.5), floori(py + 0.5)])) * 2.0 - 1.0) * amp
			ox.append(px + nx * off); oy.append(py + ny * off)
		s += length
	xs.clear(); xs.append_array(ox)
	ys.clear(); ys.append_array(oy)


## Round to whole native pixels (half up), dropping consecutive duplicates.
static func _snap(xs: PackedFloat64Array, ys: PackedFloat64Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in xs.size():
		var p := Vector2(floori(xs[k] + 0.5), floori(ys[k] + 0.5))
		if out.is_empty() or out[out.size() - 1] != p:
			out.append(p)
	while out.size() > 1 and out[0] == out[out.size() - 1]:
		out.remove_at(out.size() - 1)
	return out
