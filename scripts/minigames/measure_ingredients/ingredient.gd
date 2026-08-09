extends RigidBody2D
class_name Ingredient

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var ingredient_val : int = 0
var clickable : bool = false
var moving : bool = false
var pos_to_move : Vector2

var tween : Tween

var zero_velocity_flag : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.region_rect.position.x = ingredient_val * sprite_2d.region_rect.size.x
	mass = randi_range(1,3)

func _physics_process(delta: float) -> void:
	if moving && pos_to_move != global_position:
		pos_to_move = get_global_mouse_position()
		move_ingredient(pos_to_move, delta)
	if zero_velocity_flag:
		zero_velocity(delta, Vector2.ZERO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if clickable && event.is_action_pressed("left_click"):
		moving = true
		set_deferred("gravity_scale", 0)
	if event.is_action_released("left_click"):
		moving = false
		set_deferred("gravity_scale", 1)
		
	if event.is_action_pressed("debug_info"):
		zero_velocity_flag = true

func reset_tween(make_new : bool = false) -> void:
	if tween:
		tween.kill()
	if make_new:
		tween = create_tween()

func move_ingredient(pos : Vector2, delta : float = 1.0) -> void:
	#reset_tween(true)
	#tween.tween_property(self, "global_position", pos, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var vector_to_go : Vector2 = pos - global_position
	var force : Vector2
	zero_velocity(delta, vector_to_go)
	force = (vector_to_go.normalized() * mass * 500) + zero_velocity(delta, vector_to_go)
	apply_central_force(force)
	
func zero_velocity(delta : float, vector_to_go : Vector2) -> Vector2:
	var x_vel = linear_velocity.x
	var y_vel = linear_velocity.y
	var x_cancel_force : float = 0.0
	var y_cancel_force : float = 0.0
	
	if sign(x_vel) != sign(vector_to_go.x):
		x_cancel_force = -x_vel * mass / delta
	if sign(y_vel) != sign(vector_to_go.y):
		y_cancel_force = -y_vel * mass / delta
	
	zero_velocity_flag = false
	return Vector2(x_cancel_force, y_cancel_force)


func _on_mouse_entered() -> void:
	clickable = true

func _on_mouse_exited() -> void:
	clickable = false
