extends Node2D
class_name SequenceGame

@warning_ignore("unused_signal")
signal check_order
@warning_ignore("unused_signal")
signal make_tile(rune_val : int, start_pos : Vector2)

@onready var timer: Timer = $Timer
var reset_seq : bool = false

var slot_scene = preload("uid://8grqanudisur")
var tile_scene = preload("uid://b4sxmvjrw2fwc")
var spawn_scene = preload("uid://cwy0x7fl2yjy2")

@onready var slots_array : Array[RuneTileSlot]
@onready var tiles_array : Array[RuneTileBase]
const ARRAY_LENGTH : int = 12
var sequence_order : Array[int]
@export var sequence_length : int = 1
const MAX_SEQ_LEN : int = ARRAY_LENGTH - 1
var num_rune_symbols : int = 10
const INPUT_LENGTH : int = 8

var pattern_modifier : Array[Array] = [
	["normal", "Pattern As Seen"],
	["mirrored", "Pattern Reversed"],
	["shifted", "Starting Point Shifted By", 0],
	["inverted", "Values Inverted (1 = 0, 2 = 9, ...)"]
]

var difficulty : float = 1.0
var num_modifiers : int
var mod_list : Array = [0,1,2,3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slots_array.resize(INPUT_LENGTH)
	tiles_array.resize(INPUT_LENGTH)
	
	@warning_ignore("integer_division")
	var x_pos = floor(ARRAY_LENGTH / 2)
	for s in range(0,ARRAY_LENGTH):
		var x = ((s - x_pos) * 32) - (((ARRAY_LENGTH % 2) - 1) * 16)
		var sequence_slot : RuneTileSlot = slot_scene.instantiate()
		sequence_slot.global_position = Vector2(x, -56)
		get_node("RuneSequenceContainer").add_child(sequence_slot)
		sequence_slot.tile_area.monitorable = false
		sequence_slot.tile_area.monitoring = false
		
	x_pos = floor(INPUT_LENGTH / 2)
	for s in range(0,INPUT_LENGTH):
		var x = ((s - x_pos) * 32) - (((INPUT_LENGTH % 2) - 1) * 16)
		var new_slot : RuneTileSlot = slot_scene.instantiate()
		slots_array[s] = new_slot
		new_slot.global_position = Vector2(x, -16)
		get_node("RuneTileSlotContainer").add_child(new_slot)
		
	x_pos = floor(num_rune_symbols / 2)
	for s in range(0,num_rune_symbols):
		@warning_ignore("integer_division")
		var x = ((s - x_pos) * 24) - (((num_rune_symbols % 2) - 1) * 12)
		var new_spawn : RuneTileSpawn = spawn_scene.instantiate()
		new_spawn.rune_val = s + 1
		new_spawn.starting_pos = Vector2(x, 48)
		get_node("RuneTileSpawnContainer").add_child(new_spawn)
		
	populate_sequence()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		populate_sequence(true)
		clear_board()

func populate_sequence(restart : bool = false) -> void:
	if restart:
		for each in get_node("RuneSequenceContainer").get_children():
			if each is RuneTileBase:
				each.queue_free()
		await get_tree().process_frame
	
	num_modifiers = ceil(difficulty / 10.0)
	mod_list.shuffle()
	
	sequence_length = randi_range(3,MAX_SEQ_LEN)
	sequence_order.clear()
	print("--------------------------------")
	for mod_index in range(0,num_modifiers):
		var index : int = mod_list[mod_index]
		if num_modifiers > 1 && pattern_modifier[index][0] == "normal":
			continue
		print(pattern_modifier[index][0] + ": " + pattern_modifier[index][1])
		if pattern_modifier[index][0] == "shifted":
			pattern_modifier[index][2] = randi_range(1,MAX_SEQ_LEN)
			print("Shift = " + str(pattern_modifier[index][2]))
	
	var sequence : Array[int]
	for i in range(0,num_rune_symbols):
		sequence.append(i + 1)
	for n in range(0,sequence_length):
		sequence_order.append(sequence.pick_random())
	while sequence_order[0] == sequence_order[sequence_length - 1]:
		sequence_order[sequence_length - 1] = sequence.pick_random()
		
	@warning_ignore("integer_division")
	var x_pos = floor(ARRAY_LENGTH / 2)
	for s in range(0,ARRAY_LENGTH):
		var x = ((s - x_pos) * 32) - (((ARRAY_LENGTH % 2) - 1) * 16)
		
		var sequence_tile : RuneTileBase = tile_scene.instantiate()
		sequence_tile.starting_pos = Vector2(x, -56)
		sequence_tile.rune_val = sequence_order[s % sequence_length]
		get_node("RuneSequenceContainer").add_child(sequence_tile)
		sequence_tile.tile_area.monitorable = false
		sequence_tile.tile_area.monitoring = false

func clear_board() -> void:
	for each in get_node("RuneTileBaseContainer").get_children():
		each.queue_free()
	await get_tree().process_frame

func slot_tile(slot : RuneTileSlot, tile : RuneTileBase):
	var slot_index = slots_array.find(slot)
	remove_tile(tile)
	if tiles_array[slot_index] != null:
		remove_tile(tiles_array[slot_index], true)
	
	tiles_array[slot_index] = tile
	tile.new_rest_pos(slot.tile_center.global_position)
	tile.move_tile()
	tile.slotted = true
	
	emit_signal("check_order")
	
func remove_tile(tile : RuneTileBase, move_home : bool = false):
	var slot_index = tiles_array.find(tile)
	if slot_index != -1:
		tiles_array[slot_index] = null
		#tile.slotted = false
		if move_home:
			tile.new_rest_pos()
			tile.move_tile()

func not_null(tile):
	return tile != null
func order_check(t : int) -> bool:
	var mirror_mod = 0
	var shift = 0
	var invert_mod = 0
	
	for m in range(0, num_modifiers):
		if m >= 4:
			break
		
		if mod_list[m] == 1:
			mirror_mod = 1 - INPUT_LENGTH
		elif mod_list[m] == 2:
			shift = pattern_modifier[mod_list[m]][2]
		elif mod_list[m] == 3:
			invert_mod = 11
	
	return abs(invert_mod - tiles_array[abs(t + mirror_mod)].rune_val) != sequence_order[((t + ARRAY_LENGTH + shift) % sequence_length)]

func _on_check_order() -> void:
	if not tiles_array.all(not_null):
		return
	for t in range(0,INPUT_LENGTH):
		if order_check(t):
			print("INCORRECT ORDER")
			difficulty /= 2.0
			difficulty = ceil(difficulty)
			timer.start(1)
			return
	print("CORRECT ORDER")
	difficulty += 2.0
	reset_seq = true
	timer.start(1)
	
func make_another_tile(tile : RuneTileBase) -> void:
	var tile_inst : RuneTileBase = tile_scene.instantiate()
	tile_inst.starting_pos = tile.starting_pos
	tile_inst.rune_val = tile.rune_val
	get_node("RuneTileBaseContainer").add_child(tile_inst)


func _on_make_tile(rune_val: int, start_pos : Vector2) -> void:
	var tile_inst : RuneTileBase = tile_scene.instantiate()
	tile_inst.rune_val = rune_val
	tile_inst.starting_pos = start_pos
	get_node("RuneTileBaseContainer").add_child(tile_inst)
	tile_inst.click_on()


func _on_timer_timeout() -> void:
	if reset_seq:
		populate_sequence(reset_seq)
		reset_seq = false
	clear_board()
