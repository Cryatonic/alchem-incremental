extends RigidBody2D
class_name Ingredient

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var ingredient_val : int = 0
var clickable : bool = false
var moving : bool = false
var pos_to_move : Vector2

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.region_rect.position.x = ingredient_val * sprite_2d.region_rect.size.x
	mass = randi_range(1,3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving && pos_to_move != get_global_mouse_position():
		pos_to_move = get_global_mouse_position()
		move_ingredient(pos_to_move)

func _input(event: InputEvent) -> void:
	if clickable && event.is_action_pressed("left_click"):
		moving = true
		set_deferred("gravity_scale", 0)
	if event.is_action_released("left_click"):
		moving = false
		set_deferred("gravity_scale", 1)

func reset_tween(make_new : bool = false) -> void:
	if tween:
		tween.kill()
	if make_new:
		tween = create_tween()

func move_ingredient(pos : Vector2) -> void:
	reset_tween(true)
	tween.tween_property(self, "global_position", pos, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	clickable = true

func _on_mouse_exited() -> void:
	clickable = false
