class_name AbilityGate
extends Node2D
## A note-gated passage (spec §3.1). A physical blocker over an opening or an internal
## corridor that lifts the instant the player owns `required_note` — the grey-box stand-in
## for the note ability that will animate the crossing in M11. Ownership is the source of
## truth (NoteInventory is an autoload that persists across room re-instancing), so unlike a
## melody Door this needs no WorldState: it just re-checks `has()` on _ready.
##
## No `space` interaction and no melody: it is not an Interactable. It opens on ownership.

@export var required_note: String = ""
## Into the room, like room.gd's `inward`: the passage axis. Orients the grey-box gap's broken
## ends now; M10 art later.
@export var facing: Vector2i = Vector2i(0, 1)
@export var slab_size: Vector2 = Vector2(72.0, 90.0)

var _blocker: CollisionShape2D
var _shut := true


func _ready() -> void:
	_add_blocker()
	if NoteInventory.has(required_note):
		_open()
	else:
		NoteInventory.note_collected.connect(_on_note_collected)


func _on_note_collected(note_id: String) -> void:
	if note_id == required_note:
		_open()


func _open() -> void:
	if _blocker != null:
		_blocker.set_deferred("disabled", true)
	_shut = false
	queue_redraw()


## Grey-box placeholder until M11 draws the real crossing (owner, 2026-09-28): while shut, the
## blocker's footprint is a dark gap with broken plank ends reaching in from both approaches, so
## the player sees why the way is closed instead of walking into an invisible wall.
func _draw() -> void:
	if not _shut:
		return
	var half := slab_size * 0.5
	draw_rect(Rect2(-half, slab_size), EnvPalette.color("rock_void"), true)
	var along := Vector2(absi(facing.x), absi(facing.y))
	var across := Vector2(along.y, along.x)
	var half_along := half.dot(along)
	var half_across := half.dot(across)
	var plank := EnvPalette.color("rock_mid")
	for side: float in [-1.0, 1.0]:
		for i in 3:
			var length := 8.0 + 6.0 * float((i + int(side > 0.0)) % 2)
			var c := along * side * (half_along - length * 0.5) + across * (float(i) - 1.0) * half_across * 0.55
			var size := along * length + across * 8.0
			draw_rect(Rect2(c - size * 0.5, size), plank, true)


func _add_blocker() -> void:
	var body := StaticBody2D.new()
	var shape := RectangleShape2D.new()
	shape.size = slab_size
	_blocker = CollisionShape2D.new()
	_blocker.shape = shape
	body.add_child(_blocker)
	add_child(body)
