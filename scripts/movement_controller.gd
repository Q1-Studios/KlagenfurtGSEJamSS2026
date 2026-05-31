class_name MovementController
extends Node

@export_group("Skating")
@export var max_speed := 30.0       
@export var acceleration := 100.0
@export var deceleration := 70.0
@export var air_deceleration := 10.0
@export var air_acceleration := 40.0
@export var coasting := 20.0
@export var threshhold := 0.1 
@export var acceleration_penalty := 0.4
@export var max_acceleration_penalty := 10.0
# p(x)=2^(-a x)

@export_group("Turning")
@export var low_speed_slope := 7.1 # a
@export var high_speed_slope := 0.4 # b
@export var high_speed_punishment := 1.9 # p
@export var low_speed_limit_factor := 1.5 # k
# f(x)=((a*((1)/(k)) x)/(1+(b*((1)/(k)) x)^(p)))
@export var min_turning_factor := 1.0
@export var allow_for_air_turning := true
@export var air_turning_factor := 0.5
# max(f(x), min_turn)
@export var allow_sliding := false

@export_group("Jumping")
@export var jump_force := 20.0
@export var coyote_time := 0.15
@export var gravity := -30.0

signal landed


@onready var player_model: Node3D = %PlayerModel

# config var - no export
var ahead = Vector3.RIGHT # Front of player, change es necessary

# script controlled vars
var is_grinding: bool = false
var is_grounded = true
var previous_direction = 0
var coyote_timer = 0.0
var current_speed = 0.0
var last_steer_amount: float = 0.5
var was_on_floor = false

# constants
const STEER_SPEED = 5.0

func handle_movement(player: CharacterBody3D, delta: float) -> void:
	if player.is_on_floor():
		if !was_on_floor:
			player_model.land()
			landed.emit()
			was_on_floor = true
		is_grounded = true
		coyote_timer = coyote_time
		
	elif coyote_time > 0.0:
		coyote_time -= delta
	else:
		is_grounded = false
		was_on_floor = false
	
	if not is_grinding:
		_handle_player_turning(player, delta)
	
	_handle_forward_movement(player, delta)
	_handle_gravity(player, delta)
	_handle_jump(player, delta)
	

func _handle_player_turning(player: CharacterBody3D, delta: float) -> void:
	var raw_turn = Input.get_axis("move_right", "move_left") 
	var turn_speed := _calculate_AngularVelocity(player.velocity.length())
	if not is_grounded and not allow_for_air_turning:
		turn_speed = air_turning_factor
		
	var turn_amount = raw_turn * turn_speed * delta
	player.rotate(Vector3.UP, turn_amount)
	
	# Play steer animation
	# 0 -> left, 0.5 -> straight, 1.0 -> right
	var sanitized_turn_amount = ((raw_turn * -1.0) + 1.0) / 2
	var steer_amount = clampf(sanitized_turn_amount, 0.0, 1.0)
	last_steer_amount = lerpf(last_steer_amount, steer_amount, STEER_SPEED * delta)
	player_model.setSteer(last_steer_amount)
	
	if not allow_sliding:
		player.velocity = player.velocity.rotated(Vector3.UP, turn_amount)
		
func _handle_forward_movement(player: CharacterBody3D, delta: float) -> void:
	var raw_input = Input.get_axis("accelerate", "decelerate")
	var move_direction = Vector3.ZERO + player.global_basis.z * raw_input	
	
	var forward_speed = -player.velocity.dot(player.global_basis.z)
	var velocity_percent = clamp(forward_speed / max_speed, 0.0, 1.0)
	var final_acceleration_penalty = _calculate_acceleration_acceleration_penalty(velocity_percent)
	var scaled_acceleration = acceleration * final_acceleration_penalty
	
	var xz_velocity = player.velocity * (Vector3.ONE - Vector3.UP)
	
	if raw_input < 0 and is_grounded:
		xz_velocity = xz_velocity.move_toward(move_direction * max_speed, scaled_acceleration * delta)
		if not is_grinding:
			player_model.start_moving()
	elif raw_input < 0:
		xz_velocity = xz_velocity.move_toward(move_direction * max_speed, air_acceleration * delta)
	elif raw_input > 0 and is_grounded:
		xz_velocity = xz_velocity.move_toward(Vector3.ZERO, deceleration * delta)
		if not is_grinding:
			player_model.start_moving()
	elif raw_input > 0:
		xz_velocity = xz_velocity.move_toward(Vector3.ZERO, air_deceleration * delta)
	elif is_grounded:
		xz_velocity = xz_velocity.move_toward(Vector3.ZERO, coasting * delta)

	player.velocity = player.velocity * Vector3.UP + xz_velocity
	current_speed = player.velocity.length()

	if current_speed == 0.0 and not is_grinding:
		player_model.start_idling()
	
	
func _handle_jump(player: CharacterBody3D, _delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_grounded:
		player_model.start_jump()
		player.velocity.y = jump_force

func _handle_gravity(player: CharacterBody3D, delta: float) -> void:
	player.velocity.y += gravity * delta

				
func _calculate_AngularVelocity(velocity: float) -> float:
	var f_x := (
		(
			low_speed_slope * ((1 / low_speed_limit_factor) * velocity)
		) / (
			1 + (high_speed_slope * (
				((1 / low_speed_limit_factor) * velocity)**high_speed_punishment)
				)
			)
		)
		
	return max(f_x, min_turning_factor)
	
func _calculate_acceleration_acceleration_penalty(velocity_percent: float) -> float:
	var scaled_velocity_percent = velocity_percent * max_acceleration_penalty
	return 2**(-(acceleration_penalty*scaled_velocity_percent))

func is_about_to_land(player: CharacterBody3D, timeframe: float, return_true_on_ground: bool) -> bool:
	if is_grounded:
		return return_true_on_ground
		
	var world_state = player.get_world_3d().direct_space_state
	var gravity_vector = Vector3.UP * gravity
	
	var start_pos = player.global_position
	var player_displacement = (player.velocity * timeframe) + (0.5 * gravity_vector * pow(timeframe, 2))
	var end_pos = start_pos + player_displacement
	
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	query.exclude = [player.get_rid()]
	
	var result = world_state.intersect_ray(query)
	return !result.is_empty()
	

func _on_toggle_grinding(_is_grinding: bool) -> void:
	is_grinding = _is_grinding
