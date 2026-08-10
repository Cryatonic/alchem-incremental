extends Node2D
class_name MeasIngredGame

@onready var ingredient_container: Node2D = $IngredientContainer
@onready var scale_object: Scale = $Scale

var l_cup_bodies : Array
var r_cup_bodies : Array

const FRAME_WAIT_TIME : int = 3
var frames_waited : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	l_cup_bodies = scale_object.l_cup_detect_area.get_overlapping_bodies()
	r_cup_bodies = scale_object.r_cup_detect_area.get_overlapping_bodies()
	
	if l_cup_bodies.size() > 0 or r_cup_bodies.size() > 0:
		if frames_waited < FRAME_WAIT_TIME:
			frames_waited += 1
		else:
			scale_object.l_cup_held_bodies = determine_held_bodies(l_cup_bodies)
			scale_object.r_cup_held_bodies = determine_held_bodies(r_cup_bodies)
			frames_waited = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_info"):
		print(scale_object.r_cup_held_bodies)
		print(scale_object.l_cup_held_bodies)
		print("----------------------------")

func determine_held_bodies(ingreds : Array) -> Array[Ingredient]:
	var touching_cup : bool = false
	var held_ingreds : Array[Ingredient]
	
	for ingred : Ingredient in ingreds:
		var coll_bodies : Array = ingred.get_colliding_bodies()
		for body in coll_bodies:
			if body is AnimatableBody2D:
				touching_cup = true
				held_ingreds.append(ingred)
	
	if touching_cup:
		for ingred : Ingredient in ingreds:
			var coll_bodies : Array = ingred.get_colliding_bodies()
			if coll_bodies.size() == 0:
				continue
			for body in coll_bodies:
				if body is not Ingredient:
					continue
				if held_ingreds.find(body) == -1:
					held_ingreds.append(body)
	return held_ingreds
