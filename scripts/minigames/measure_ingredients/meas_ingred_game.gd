extends Node2D
class_name MeasIngredGame

@onready var ingredient_container: Node2D = $IngredientContainer
@onready var scale_object: Scale = $Scale

var l_cup_bodies : Array
var r_cup_bodies : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	l_cup_bodies = scale_object.l_cup_detect_area.get_overlapping_bodies()
	r_cup_bodies = scale_object.r_cup_detect_area.get_overlapping_bodies()
	
	if l_cup_bodies.size() > 0 or r_cup_bodies.size() > 0:
		scale_object.l_cup_held_bodies = determine_held_bodies(l_cup_bodies)
		scale_object.r_cup_held_bodies = determine_held_bodies(r_cup_bodies)
	else:
		scale_object.l_cup_held_bodies.clear()
		scale_object.r_cup_held_bodies.clear()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_info"):
		print(scale_object.r_cup_held_bodies)
		print(scale_object.l_cup_held_bodies)
		print("----------------------------")

func determine_held_bodies(wpo : Array) -> Array[WeightedPhysicsObject]:
	var touching_cup : bool = false
	var held_objects : Array[WeightedPhysicsObject]
	
	for obj : WeightedPhysicsObject in wpo:
		var coll_bodies : Array = obj.get_colliding_bodies()
		for body in coll_bodies:
			if body is AnimatableBody2D:
				touching_cup = true
				held_objects.append(obj)
	
	if touching_cup:
		for obj : WeightedPhysicsObject in wpo:
			var coll_bodies : Array = obj.get_colliding_bodies()
			if coll_bodies.size() == 0:
				continue
			for body in coll_bodies:
				if body is not WeightedPhysicsObject:
					continue
				if held_objects.find(body) == -1:
					held_objects.append(body)
	return held_objects
