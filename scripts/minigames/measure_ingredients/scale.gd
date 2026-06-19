extends Node2D
class_name Scale

@onready var l_cup_detect_area: Area2D = $LCupDetectArea
@onready var r_cup_detect_area: Area2D = $RCupDetectArea

var l_cup_weight : int = 0
var r_cup_weight : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	check_weights(l_cup_detect_area)
	check_weights(r_cup_detect_area)

func _input(_event: InputEvent) -> void:
	pass

func check_weights(area : Area2D) -> int:
	var held_weight : int = 0
	
	var bodies : Array = area.get_overlapping_bodies()
	for body in bodies:
		if body is Ingredient:
			held_weight += body.mass
	
	return held_weight

func tip_scale() -> void:
	pass
