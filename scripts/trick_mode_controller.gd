class_name TrickController
extends Node

@export var time_for_tricks := 2.0


@onready var movementController := %MovementController
var character_body: CharacterBody3D
var slow_mo: float
var slow_mo_is_active: bool

@onready var trickInputUI = $"../../TrickInputSubviewPort/TrickSequenceDisplay"
var trickSprites: Array
var upImg = load("res://assets/sprites/arrowUp.png")
var rightImg = load("res://assets/sprites/arrowRight.png")
var downImg = load ("res://assets/sprites/arrowDown.png")
var leftImg = load("res://assets/sprites/arrowLeft.png")

@onready var wrongInputTimer = $"../WrongInputTimer"

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
	getSprites()
	create_goal_sequence()

func _process(delta: float) -> void:
	if is_active && wrongInputTimer.time_left <= 0:
		var time_needed_for_tricks = time_for_tricks
		if slow_mo_is_active:
			time_needed_for_tricks = time_for_tricks / slow_mo
		
		if (movementController.is_about_to_land(character_body, time_needed_for_tricks, false)):
			is_active = false
			_reset()
			print("Trick Mode over")
		
		if (sequence_input_index >= sequence_length and not failed) or won:
			_handle_success()
		elif failed:
			_handle_failure()
		else:
			_evaluate_input()	

func instanciate(player: CharacterBody3D, slow_mo_factor: float) -> void:
	character_body = player
	slow_mo = slow_mo_factor

func _handle_success() -> void:
	is_active = false
	_reset()
	print("WON")
	emit_signal("trick_sequence_success")
	getSprites
func _handle_failure() -> void:
	sequence_input_index = 0
	failed = false
	print("Failed sequence")
	

func _evaluate_input() -> void:
	var input_vector = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	
	
	var left = input_vector.x == -1.0 and Input.is_action_just_pressed("LEFT")
	var right = input_vector.x == 1.0 and Input.is_action_just_pressed("RIGHT")
	var up = input_vector.y == -1.0 and Input.is_action_just_pressed("UP")
	var down = input_vector.y == 1.0 and Input.is_action_just_pressed("DOWN")
	
	if left:
		if sequence[sequence_input_index] == "LEFT":
			trickSprites[sequence_input_index].self_modulate = Color (0, 1, 0)
			sequence_input_index += 1
		else:
			print("Pressed LEFT should have been ", sequence[sequence_input_index])
			startMistakeTimer()
			mistakeModulate()
			failed = true
	
	if right:
		if sequence[sequence_input_index] == "RIGHT":
			trickSprites[sequence_input_index].self_modulate = Color (0, 1, 0)
			sequence_input_index += 1
		else:
			print("Pressed RIGHT should have been ", sequence[sequence_input_index])
			startMistakeTimer()
			mistakeModulate()
			failed = true
			
	if up:
		if sequence[sequence_input_index] == "UP":
			trickSprites[sequence_input_index].self_modulate = Color (0, 1, 0)
			sequence_input_index += 1
		else:
			print("Pressed UP should have been ", sequence[sequence_input_index])
			startMistakeTimer()
			mistakeModulate()
			failed = true
			
	if down:
		if sequence[sequence_input_index] == "DOWN":
			trickSprites[sequence_input_index].self_modulate = Color (0, 1, 0)
			sequence_input_index += 1
		else:
			print("Pressed DOWN should have been ", sequence[sequence_input_index])
			startMistakeTimer()
			mistakeModulate()
			failed = true

func create_goal_sequence() -> void:
	_reset()
	for i in range(sequence_length):
		sequence.append(input[rng.randi_range(0, 3)])
	print(sequence)
	is_active = true
	setSprites()
	displayTrickSequence()
	
	
func _reset() -> void:
	sequence = []
	sequence_input_index = 0
	failed = false
	won = false
	resetModulate()
	trickInputUI.set_visible(false)
	
func toggle_slow_mo(is_active: bool) -> void:
	slow_mo_is_active = is_active

func displayTrickSequence() -> void:
	trickInputUI.set_visible(true)

func getSprites() -> void:
	trickSprites = trickInputUI.get_children()

func setSprites() -> void:
	var i = 0
	for each in sequence:
		match each:
			"UP":
				trickSprites[i].texture = upImg
			"RIGHT":
				trickSprites[i].texture = rightImg
			"DOWN":
				trickSprites[i].texture = downImg
			"LEFT":
				trickSprites[i].texture = leftImg
		i += 1
		
func mistakeModulate() -> void:
	for each in trickSprites:
		each.self_modulate = Color(1, 0, 0)
		
func resetModulate() -> void:
	for each in trickSprites:
		each.self_modulate = Color(1, 1, 1)
	getSprites()

func startMistakeTimer() -> void:
	wrongInputTimer.start()


func _on_wrong_input_timer_timeout() -> void:
	for each in trickSprites:
		each.self_modulate = Color(1, 1, 1)
