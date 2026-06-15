extends Node2D
class_name RuneTileSlot

@onready var tile_area: Area2D = $TileArea
@onready var tile_center: Marker2D = $TileCenter

var held_tile : RuneTileBase = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func take_rune(rune : RuneTileBase):
	pass

func _on_tile_area_area_entered(area: Area2D) -> void:
	pass

func _on_tile_area_area_exited(area: Area2D) -> void:
	pass
