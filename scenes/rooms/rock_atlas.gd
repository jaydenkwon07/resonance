class_name RockAtlas
extends RefCounted
## The cave's surface textures (§3.2): five floor tiles and the rock body, GENERATED
## procedurally rather than loaded from a PNG, so palette.json retints the whole cave (§3.3).
## The only file that knows how rock and floor look (§4). RoomWalls lays them under the
## smoothed wall loops — the walls' shape comes from WallOutline, not from here.
##
## [M7] Replaced RockTileSet when the 45° bevel was retired: the 47-tile blob terrain and its
## per-tile collision/occluders went with it. What stayed is exactly the art the smooth walls
## use — the floor variants and the interior rock tile, drawn from the same seeds, so the
## cave looks the same as before the retirement.
##
## Drawn FLAT, in palette values, form but NOT lighting (§8a, D-M4-10): the PointLight2D
## system lights the room, so baked directional shading here would light twice and go muddy.
## Tones and grit densities come from a RockStyle.
##
## Layout (one row, tiles `tp` square): cols 0-2 floor speckle variants, cols 3-4 rare floor
## detail (a crack, a pebble cluster), col 5 the rock body.

const FLOOR_BASE_VARIANTS := 3   # cols 0-2 are interchangeable floor
const FLOOR_DETAIL_VARIANTS := 2 # cols 3-4 are rare detail
const FLOOR_COLS := FLOOR_BASE_VARIANTS + FLOOR_DETAIL_VARIANTS
const ROCK_COL := FLOOR_COLS
## The seed the M5 atlas drew its fully-interior rock tile with (500 + its blob index, 46), kept
## so the rock body's facets land where they always have.
const _ROCK_SEED := 546

# Internal facet/grit tones (palette NAMES): sub-tones the flat textures are built from, a
# lighter fleck and a darker crack around the body. Structural, not per-room tuning.
const _ROCK_FLECK := "rock_shadow"
const _ROCK_CRACK := "rock_void"
const _ROCK_GRAIN := "rock_mid"
const _FLOOR_PIT := "rock_deep"
const _FLOOR_GRAIN := "rock_mid"
const _FLOOR_INK := "rock_void"


static func build(tp: int, style: RockStyle) -> Image:
	var img := Image.create((FLOOR_COLS + 1) * tp, tp, false, Image.FORMAT_RGBA8)
	for v in FLOOR_COLS:
		_draw_floor(img, v * tp, tp, v, style)
	_draw_rock_body(img, ROCK_COL * tp, tp, style)
	return img


## The atlas rect of floor `variant` (0..2 base, 3..4 detail).
static func floor_rect(variant: int, tp: int) -> Rect2i:
	return Rect2i(clampi(variant, 0, FLOOR_COLS - 1) * tp, 0, tp, tp)


static func rock_body_rect(tp: int) -> Rect2i:
	return Rect2i(ROCK_COL * tp, 0, tp, tp)


## Floor: the style's floor_tone ground (LIGHTER than the rock body, so the room reads without
## leaning on the rim), with sparse low-grit — darker pits and a few lighter grains,
## deterministic per variant. Variant 3 is a hairline crack, variant 4 a small pebble cluster.
static func _draw_floor(img: Image, ox: int, tp: int, variant: int, style: RockStyle) -> void:
	img.fill_rect(Rect2i(ox, 0, tp, tp), EnvPalette.color(style.floor_tone))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1000 + variant
	var pit := EnvPalette.color(_FLOOR_PIT)
	var grain := EnvPalette.color(_FLOOR_GRAIN)
	var ink := EnvPalette.color(_FLOOR_INK)
	for _i in style.floor_pit_count:
		_blob(img, ox, tp, rng.randi_range(1, tp - 3), rng.randi_range(1, tp - 3), 2, pit)
	for _i in maxi(1, style.floor_pit_count / 2):
		_blob(img, ox, tp, rng.randi_range(1, tp - 3), rng.randi_range(1, tp - 3), 2, grain)
	for _i in 2:
		img.set_pixel(ox + rng.randi_range(0, tp - 1), rng.randi_range(0, tp - 1), ink)
	if variant == FLOOR_BASE_VARIANTS:
		for i in 9:  # a hairline crack sloping down-right
			img.set_pixel(ox + 4 + i, 5 + int(i / 2), ink)
	elif variant > FLOOR_BASE_VARIANTS:
		var cx := tp / 2 + rng.randi_range(-4, 4)  # a small pebble cluster
		var cy := tp / 2 + rng.randi_range(-4, 4)
		for _i in 5:
			_blob(img, ox, tp, cx + rng.randi_range(-3, 3), cy + rng.randi_range(-3, 3), 2, pit)
		for _i in 2:
			_blob(img, ox, tp, cx + rng.randi_range(-3, 3), cy + rng.randi_range(-3, 3), 2, grain)


## Rock body: a flat rock_tone (DARKER than the floor) with subtle low-contrast facets — a
## lighter fleck, a darker crack, a rare bright grain, no directional gradient (§8a). The
## wall-meets-floor rim is RoomWalls' Line2D, not baked here.
static func _draw_rock_body(img: Image, ox: int, tp: int, style: RockStyle) -> void:
	img.fill_rect(Rect2i(ox, 0, tp, tp), EnvPalette.color(style.rock_tone))
	var rng := RandomNumberGenerator.new()
	rng.seed = _ROCK_SEED
	var fleck := EnvPalette.color(_ROCK_FLECK)
	var crack := EnvPalette.color(_ROCK_CRACK)
	var grain := EnvPalette.color(_ROCK_GRAIN)
	for _i in style.rock_facet_count:
		_blob(img, ox, tp, rng.randi_range(2, tp - 4), rng.randi_range(2, tp - 4), rng.randi_range(2, 3), fleck)
	for _i in maxi(1, style.rock_facet_count - 2):
		img.set_pixel(ox + rng.randi_range(1, tp - 2), rng.randi_range(1, tp - 2), crack)
	for _i in 2:
		img.set_pixel(ox + rng.randi_range(1, tp - 2), rng.randi_range(1, tp - 2), grain)


## A small filled square of `col`, clamped to the tile — the unit of facet grit.
static func _blob(img: Image, ox: int, tp: int, cx: int, cy: int, size: int, col: Color) -> void:
	for yy in size:
		for xx in size:
			var px := cx + xx
			var py := cy + yy
			if px >= 0 and px < tp and py >= 0 and py < tp:
				img.set_pixel(ox + px, py, col)
