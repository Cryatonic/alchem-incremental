extends Node2D
class_name RuneTileBase

signal finished_moving

@onready var game : SequenceGame = $"../../"

@onready var tile_area: Area2D = $TileArea
@onready var tile_center: Marker2D = $TileCenter
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rune: Sprite2D = $Rune

var clickable : bool = false
var clicked : bool = false
var moving : bool = false
var done_moving : bool = false
var slotted : bool = false

#Where the rune tile will default move to when unselected
#starting_pos is origin point in play area
@export var starting_pos : Vector2
var rest_pos : Vector2
var pos_to_move : Vector2 = Vector2.ZERO

#The region offset for which rune to display
#Currently using numbers, and so is the actual value, thus offset needs a -1
@export var rune_val : int = 1

var tween : Tween
#var hovered_slot : RuneTileSlot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = starting_pos
	rest_pos = starting_pos
	rune.region_rect.position.x = (rune_val - 1) * rune.region_rect.size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if moving and pos_to_move != get_global_mouse_position():
		pos_to_move = get_global_mouse_position()
		move_tile(pos_to_move)
	if pos_to_move == global_position && not done_moving:
		emit_signal("finished_moving")

func _input(event: InputEvent) -> void:
	if clickable or clicked:
		if event.is_action_pressed("left_click") && clickable:
			click_on()
		if event.is_action_released("left_click") && clicked:
			clicked = false
			var slot = determine_closest_overlapping_slot()
			if slot != null:
				game.slot_tile(slot, self)
				moving = false
			else:
				moving = false
				game.remove_tile(self, true)
				move_tile()
			sprite_2d.z_index = 0
			rune.z_index = 0

func click_on() -> void:
	clicked = true
	moving = true
	sprite_2d.z_index = 1
	rune.z_index = 2

func move_tile(pos : Vector2 = rest_pos) -> void:
	reset_tween(true)
	#pos_to_move = pos
	tween.tween_property(self, "global_position", pos, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	done_moving = false

func new_rest_pos(pos : Vector2 = starting_pos) -> void:
	rest_pos = pos
	
func reset_tile_pos() -> void:
	new_rest_pos()
	move_tile()

func _on_tile_area_mouse_entered() -> void:
	if tile_area.monitoring:
		clickable = true

func _on_tile_area_mouse_exited() -> void:
	if tile_area.monitoring:
		clickable = false

func reset_tween(make_new : bool = false) -> void:
	if tween:
		tween.kill()
	if make_new:
		tween = create_tween()

func determine_closest_overlapping_slot() -> RuneTileSlot:
	var closest_dist : float = 1000
	var slot : RuneTileSlot
	var dist : float
	
	for area in tile_area.get_overlapping_areas():
		var area_parent = area.get_parent()
		if area_parent is RuneTileSlot:
			dist = (area_parent.tile_area.global_position - tile_area.global_position).length()
			if dist < closest_dist:
				slot = area_parent
		
	return slot

func _on_finished_moving() -> void:
	#print("I'm done.")
	done_moving = true
	if global_position == starting_pos && not clicked:
		queue_free()
