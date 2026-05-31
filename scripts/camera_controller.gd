extends Node

@export_group("Free Camera")
@export var joystick_sensitivity: float = 3.0
@export var camera_reset_speed: float = 5.0 
@export var default_vertical_angle: float = -30.0

@export_group("Trick Camera")
@export var trick_yaw_angle: float = 135.0
@export var trick_pitch_angle: float = -20.0

@onready var camera_pivot = %CameraPivot
@onready var spring_arm = %CameraPivot/SpringArm3D

signal trick_camera_finished

var is_locked: bool = false


func _process(delta):
	if not is_locked:
		handle_camera_rotation(delta)

func handle_camera_rotation(delta):
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	if look_dir.length() > 0.05:
		camera_pivot.rotate_y(-look_dir.x * joystick_sensitivity * delta)
		spring_arm.rotate_x(-look_dir.y * joystick_sensitivity * delta)
		
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-80), deg_to_rad(-1))
	else:
		camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, 0.0, camera_reset_speed * delta)
		
		spring_arm.rotation.x = lerp_angle(spring_arm.rotation.x, deg_to_rad(default_vertical_angle), camera_reset_speed * delta)
	

func _on_trick_mode_controller_trick_sequence_success_time_info(time: float) -> void:
	if is_locked:
		return
	is_locked = true
	
	var transition_in: float = time * 0.20
	var transition_out: float = time * 0.20
	var hold_time: float = time * 0.60
	
	# shortest path target
	var current_yaw = camera_pivot.rotation.y
	var target_yaw = current_yaw + angle_difference(current_yaw, deg_to_rad(trick_yaw_angle))
	var target_pitch = deg_to_rad(trick_pitch_angle)
	
	# shortest path back
	var return_yaw = target_yaw + angle_difference(target_yaw, 0.0)
	var return_pitch = deg_to_rad(default_vertical_angle)
	
	# animation 
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# transition_in
	tween.tween_property(camera_pivot, "rotation:y", target_yaw, transition_in)
	tween.parallel().tween_property(spring_arm, "rotation:x", target_pitch, transition_in)
	
	# hold
	tween.tween_interval(hold_time)
	
	# transition_out
	tween.tween_property(camera_pivot, "rotation:y", return_yaw, transition_out)
	tween.parallel().tween_property(spring_arm, "rotation:x", return_pitch, transition_out)
	
	# clean up with lambda <3
	tween.tween_callback(func():
		# reset camera
		camera_pivot.rotation.y = 0.0
		spring_arm.rotation.x = deg_to_rad(default_vertical_angle)
	
		# unlock & emit
		is_locked = false
		trick_camera_finished.emit()
	)
