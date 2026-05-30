extends Node2D

const cursorSpeed: float = 600
const deadZone: float = 0.2
@onready var parent = $".."
func _process(delta: float) -> void:
	var move = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		)
	if move.length() < deadZone:
		move = Vector2.ZERO
	else:
		move = move.normalized()
		
	var oldPos = global_position
	global_position += move * cursorSpeed * delta

	# create new mouse event and push it to viewport to mimic mouse
	if global_position!= oldPos:
		var motionEvent: InputEventMouseMotion = InputEventMouseMotion.new()
		motionEvent.position = getCursorPos()
		get_viewport().push_input(motionEvent)
	
	#if Input.is_action_just_pressed("controller_left_click"):
		#var click: InputEventMouseButton = InputEventMouseButton.new()
		#click.button_index = MOUSE_BUTTON_LEFT
		#click.pressed = true
		#click.position = getCursorPos()
		#get_viewport().push_input(click)
		#
	#if Input.is_action_just_released("controller_left_click"):
		#var click: InputEventMouseButton = InputEventMouseButton.new()
		#click.button_index = MOUSE_BUTTON_LEFT
		#click.pressed = false
		#click.position = getCursorPos()
		#get_viewport().push_input(click)
	

func getCursorPos() -> Vector2:
	var finalPos: Vector2 = global_position
	var levelCam: Camera2D = get_viewport().get_camera_2d()
	if levelCam:
		finalPos -= levelCam.global_position
		if levelCam.anchor_mode == Camera2D.ANCHOR_MODE_DRAG_CENTER:
			finalPos += get_viewport_rect().size / 2.0
	return get_viewport().get_screen_transform().basis_xform(finalPos)
