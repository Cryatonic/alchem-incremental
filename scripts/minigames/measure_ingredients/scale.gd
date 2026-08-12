extends Node2D
class_name Scale

@onready var l_cup_detect_area: Area2D = $LeftCupBody/LCupDetectArea
@onready var r_cup_detect_area: Area2D = $RightCupBody/RCupDetectArea
@onready var scale_arm: Sprite2D = $SpriteComponents/ScaleArm

@onready var l_cup_marker: Marker2D = $SpriteComponents/ScaleArm/LCupMarker
@onready var left_cup_body: AnimatableBody2D = $LeftCupBody
@onready var r_cup_marker: Marker2D = $SpriteComponents/ScaleArm/RCupMarker
@onready var right_cup_body: AnimatableBody2D = $RightCupBody

var l_cup_weight : int = 0
var l_cup_held_bodies : Array[WeightedPhysicsObject]
var r_cup_weight : int = 0
var r_cup_held_bodies : Array[WeightedPhysicsObject]

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	l_cup_weight = check_weights(l_cup_held_bodies)
	r_cup_weight = check_weights(r_cup_held_bodies)
	tip_scale(_delta)
	if left_cup_body.global_position != l_cup_marker.global_position:
		left_cup_body.global_position = l_cup_marker.global_position
		right_cup_body.global_position = r_cup_marker.global_position

func _input(_event: InputEvent) -> void:
	pass

func check_weights(cup : Array[WeightedPhysicsObject]) -> int:
	var held_weight : int = 0
	
	for body in cup:
		@warning_ignore("narrowing_conversion")
		held_weight += body.mass
	
	return held_weight

func tip_scale(_delta : float) -> void:
	var scale_diff : int = r_cup_weight - l_cup_weight
	if abs(scale_diff) > 15:
		scale_diff = 15 * sign(scale_diff)
	var rotation_amt : int = scale_diff * 3 #45 deg / 15 positions
	reset_tween(true)
	var tip_time : float = 0.25
	tween.tween_property(scale_arm, "rotation_degrees", rotation_amt + 90, tip_time).set_trans(Tween.TRANS_SINE)

func reset_tween(make_new : bool = false) -> void:
	if tween:
		tween.kill()
	if make_new:
		tween = create_tween()
