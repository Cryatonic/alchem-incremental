extends WeightedPhysicsObject
class_name MeasureWeight

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var size : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_weight()


func set_weight():
	set_mass(pow(2, size))
	set_sprite(sprite_2d, size)
	
	var col_scale = 1 + float(size / 2.0)
	collision_shape_2d.scale = Vector2(col_scale,col_scale)
	collision_shape_2d.position.y = -size
