class_name RoomWalls
extends RefCounted
## Builds a room's walls from WallOutline's smoothed loops (M7; replaced the 45° bevel). ONE
## vertex list per loop feeds all three uses — the drawn wall, its collision and its light
## occluder — so what looks solid is solid (honest edges).
##
## Drawing, back to front, all with antialiasing off inside the 960×540 SubViewport:
##   - the rock body, RockAtlas's rock tile repeated over the padded bounds;
##   - each loop filled by nesting depth: a floor outline with the room's baked floor tiles
##     (per-cell variants from Room.floor_variant), an outcrop with the rock body;
##   - the dark rim, a closed Line2D on every loop (straddles the edge, `seam_px` wide).
## Rock is drawn by painting floor over it rather than clipping, so nothing leans on
## clip_children under the CanvasModulate + PointLight2D lighting.

## Cells of padding around the grid: the trace runs over cells -2..w, so this covers every loop,
## including the corridor carried one cell past each opening.
const PAD := 2


## Build the walls under `room` from its geometry data, at `tp` px per tile.
static func build(room: Node2D, data: Dictionary, tp: int, look: RockStyle) -> void:
	if look == null:
		look = RockStyle.new()
	var grid: Array = data.get("grid", [])
	var size := Vector2i(str(grid[0]).length() if grid.size() > 0 else 0, grid.size())
	var atlas := RockAtlas.build(tp, look)
	var rock_tex := ImageTexture.create_from_image(atlas.get_region(RockAtlas.rock_body_rect(tp)))
	var floor_tex := _bake_floor(atlas, size, tp)
	var origin := Vector2(-PAD * tp, -PAD * tp)
	var extent := Vector2(size + Vector2i(PAD, PAD) * 2) * float(tp)

	var walls := WallOutline.loops(data)
	var art := Node2D.new()
	art.name = "Walls"
	room.add_child(art)
	art.add_child(_poly(PackedVector2Array([origin, origin + Vector2(extent.x, 0), origin + extent,
		origin + Vector2(0, extent.y)]), rock_tex, Vector2.ZERO))
	for i in _by_depth(walls):
		var loop := walls[i]
		var is_floor := WallOutline.signed_area(loop) < 0.0
		art.add_child(_poly(loop, floor_tex if is_floor else rock_tex, -origin if is_floor else Vector2.ZERO))

	var body := StaticBody2D.new()
	body.name = "WallBody"
	room.add_child(body)
	for loop in walls:
		if look.seam_px > 0.0:
			var rim := Line2D.new()
			rim.points = loop
			rim.closed = true
			rim.width = look.seam_px
			rim.default_color = EnvPalette.color(look.seam_tone)
			rim.joint_mode = Line2D.LINE_JOINT_BEVEL
			art.add_child(rim)
		var shape := ConcavePolygonShape2D.new()
		shape.segments = WallOutline.segments(loop)
		var col := CollisionShape2D.new()
		col.shape = shape
		body.add_child(col)
		var occ := OccluderPolygon2D.new()
		occ.polygon = loop
		occ.closed = true
		var occluder := LightOccluder2D.new()
		occluder.occluder = occ
		room.add_child(occluder)


static func _poly(points: PackedVector2Array, tex: Texture2D, tex_offset: Vector2) -> Polygon2D:
	var p := Polygon2D.new()
	p.polygon = points
	p.texture = tex
	p.texture_offset = tex_offset
	p.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	p.antialiased = false
	return p


## The floor of every cell in the padded bounds, baked into one image with Room.floor_variant —
## so the smooth floor is pixel-for-pixel the bevel's floor wherever a loop exposes it.
static func _bake_floor(atlas: Image, size: Vector2i, tp: int) -> ImageTexture:
	var img := Image.create((size.x + PAD * 2) * tp, (size.y + PAD * 2) * tp, false, atlas.get_format())
	for y in range(-PAD, size.y + PAD):
		for x in range(-PAD, size.x + PAD):
			var src := RockAtlas.floor_rect(Room.floor_variant(x, y), tp)
			img.blit_rect(atlas, src, Vector2i(x + PAD, y + PAD) * tp)
	return ImageTexture.create_from_image(img)


## Loop indices ordered by nesting depth, so a loop inside another is painted over it (a floor
## pocket inside an outcrop still shows). Loops never touch, so testing one vertex is enough.
static func _by_depth(loops: Array[PackedVector2Array]) -> Array[int]:
	var depth: Array[int] = []
	for i in loops.size():
		var d := 0
		for j in loops.size():
			if i != j and Geometry2D.is_point_in_polygon(loops[i][0], loops[j]):
				d += 1
		depth.append(d)
	var order: Array[int] = []
	for i in loops.size():
		order.append(i)
	order.sort_custom(func(a: int, b: int) -> bool: return depth[a] < depth[b] or (depth[a] == depth[b] and a < b))
	return order

