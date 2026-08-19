extends Node2D
class_name MeasIngredGame

@onready var ingredient_container: Node2D = $IngredientContainer
@onready var scale_object: Scale = $Scale
@onready var collection_detector: Area2D = $CollectionBowl/CollectionDetector
@onready var ingred_spawn: Marker2D = $IngredBowl/IngredSpawn


var l_cup_bodies : Array
var r_cup_bodies : Array
var collection_bodies : Array

var required_mass : int
var ingred_scene : PackedScene = preload("uid://cw5gbchc2403s")

var ingred_weights : Array[float] = [1.0,5.0] #min/max

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game(randi_range(0,3))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	scales_holding()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_info"):
		print(scale_object.r_cup_held_bodies)
		print(scale_object.l_cup_held_bodies)
		print("----------------------------")

func spawn_ingredient(m : int, ingred_type : int) -> void:
	var ingred : Ingredient = ingred_scene.instantiate()
	ingred.global_position = ingred_spawn.global_position
	ingred.global_position.x += randi_range(-12,12)
	ingred.global_position.y -= get_node("IngredientContainer").get_child_count() * 8
	ingred.set_mass(m)
	ingred.set_ingred_val(ingred_type)
	get_node("IngredientContainer").add_child(ingred)

func start_game(ingred_type : int = 0) -> void:
	@warning_ignore("narrowing_conversion")
	required_mass = randi_range(ingred_weights[0],15)
	print("Required Mass = " + str(required_mass))
	var cur_mass : int = required_mass
	var ing_mass : int
	while cur_mass > 0:
		if cur_mass <= ingred_weights[1]:
			spawn_ingredient(cur_mass, ingred_type)
			break
		@warning_ignore("narrowing_conversion")
		ing_mass = randi_range(ingred_weights[0],ingred_weights[1])
		spawn_ingredient(ing_mass, ingred_type)
		cur_mass -= ing_mass
	while get_node("IngredientContainer").get_child_count() < 8:
		spawn_ingredient(randi_range(1,3), ingred_type)

func scales_holding() -> void:
	l_cup_bodies = scale_object.l_cup_detect_area.get_overlapping_bodies()
	r_cup_bodies = scale_object.r_cup_detect_area.get_overlapping_bodies()
	
	if l_cup_bodies.size() > 0 or r_cup_bodies.size() > 0:
		scale_object.l_cup_held_bodies = determine_held_bodies(l_cup_bodies)
		scale_object.r_cup_held_bodies = determine_held_bodies(r_cup_bodies)
	else:
		scale_object.l_cup_held_bodies.clear()
		scale_object.r_cup_held_bodies.clear()

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


func _on_finish_button_pressed() -> void:
	collection_bodies = collection_detector.get_overlapping_bodies()
	var held_ingred : Array[WeightedPhysicsObject] = determine_held_bodies(collection_bodies)
	for held in held_ingred:
		if held is not Ingredient:
			var index : int = held_ingred.find(held)
			held_ingred.pop_at(index)
	var total_mass_held : float = 0.0
	for held in held_ingred:
		total_mass_held += held.mass
	if total_mass_held == required_mass:
		print("CORRECT")
		for ing in get_node("IngredientContainer").get_children():
			ing.queue_free()
		await get_tree().process_frame
		start_game(randi_range(0,3))
	else:
		print("INCORRECT")
