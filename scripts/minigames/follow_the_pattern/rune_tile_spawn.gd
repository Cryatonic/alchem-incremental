extends Node2D
class_name RuneTileSpawn

@onready var click_area: Area2D = $ClickArea
@onready var rune: Sprite2D = $Rune
@export var rune_val : int = 1

var starting_pos : Vector2
var clickable : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = starting_pos
	rune.region_rect.position.x = (rune_val - 1) * rune.region_rect.size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if clickable:
		if event.is_action_pressed("left_click"):
			$"../../".emit_signal("make_tile", rune_val, starting_pos)

func _on_click_area_mouse_entered() -> void:
	clickable = true


func _on_click_area_mouse_exited() -> void:
	clickable = false
