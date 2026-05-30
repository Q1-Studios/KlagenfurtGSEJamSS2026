class_name TrickController
extends Node

var sequence_length = 4
var rng = RandomNumberGenerator.new()	
var input = ["LEFT", "RIGHT", "UP", "DOWN"]
var is_active = false
var sequence = []
var sequence_input_index = 0
var failed = false
var won = false

signal trick_sequence_success()

func _ready() -> void:
	_create_goal_sequence()

func _process(delta: float) -> void:
	if is_active:
		if (sequence_input_index >= sequence_length and not failed) or won:
			_handle_success()
		elif failed:
			_handle_failure()
		else:
			_evaluate_input()	
	
func _handle_success() -> void:
	is_active = false
	_reset()
	print("WON")
	emit_signal("trick_sequence_success")
	
func _handle_failure() -> void:
	sequence_input_index = 0
	failed = false
	print("LOST")
	

func _evaluate_input() -> void:
	var input_vector = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	
	
	var left = input_vector.x == -1.0 and Input.is_action_just_pressed("LEFT")
	var right = input_vector.x == 1.0 and Input.is_action_just_pressed("RIGHT")
	var up = input_vector.y == -1.0 and Input.is_action_just_pressed("UP")
	var down = input_vector.y == 1.0 and Input.is_action_just_pressed("DOWN")
	
	if left:
		if sequence[sequence_input_index] == "LEFT":
			sequence_input_index += 1
		else:
			print("Pressed LEFT should have been ", sequence[sequence_input_index])
			failed = true
	
	if right:
		if sequence[sequence_input_index] == "RIGHT":
			sequence_input_index += 1
		else:
			print("Pressed RIGHT should have been ", sequence[sequence_input_index])
			failed = true
			
	if up:
		if sequence[sequence_input_index] == "UP":
			sequence_input_index += 1
		else:
			print("Pressed UP should have been ", sequence[sequence_input_index])
			failed = true
			
	if down:
		if sequence[sequence_input_index] == "DOWN":
			sequence_input_index += 1
		else:
			print("Pressed DOWN should have been ", sequence[sequence_input_index])
			failed = true

func _create_goal_sequence() -> void:
	_reset()
	for i in range(sequence_length):
		sequence.append(input[rng.randi_range(0, 3)])
	print(sequence)
	is_active = true
	
func _reset() -> void:
	sequence = []
	sequence_input_index = 0
	failed = false
	won = false
	
