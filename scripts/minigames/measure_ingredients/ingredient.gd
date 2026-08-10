extends WeightedPhysicsObject
class_name Ingredient

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var ingredient_val : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_sprite(sprite_2d, ingredient_val)
	set_mass(randi_range(1,3))

func set_ingred_val(i : int):
	ingredient_val = i
