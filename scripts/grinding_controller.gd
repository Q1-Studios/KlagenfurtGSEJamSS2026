extends Node
class_name GrindingController

 
#--RAIL GRINDING VARIABLES--
@onready var rail_grind_node: RailFollower = null
@onready var camera = %PlayerCamera as Camera3D
@onready var camera_pivot = %CameraPivot as Node3D

@export var grind_ray: ShapeCast3D
@export var player: CharacterBody3D
@export var player_model: Node3D
@export var skateboard_model: Node3D

var initial_player_model_transform: Transform3D
var initial_skateboard_model_transform: Transform3D
var initial_camera_pivot_rotation: Vector3

var grinding: bool = false
var can_grind: bool = true
var target_yaw: float

signal toggle_grinding(is_grinding: bool)
 
#GRINDING
func handle_grinding(): 
	if can_grind and not grinding and is_colliding_with_rail():
		start_grinding()
	
	if grinding and rail_grind_node:
		rail_grind_node.chosen = true
		update_player_camera()
		update_player_position()
		print("Rail_grind_node.detach: {0}".format([rail_grind_node.detach]))
		if rail_grind_node.detach or Input.is_action_just_pressed("jump"):
			detach_from_rail()
 
func is_colliding_with_rail() -> bool:
	if !grind_ray.is_colliding():
		return false
		
	var collider = grind_ray.get_collider(0)
	return collider and collider.is_in_group("Rail")
 
func start_grinding():
	initial_player_model_transform = player_model.transform
	initial_skateboard_model_transform = skateboard_model.transform
	initial_camera_pivot_rotation = camera_pivot.rotation
	grinding = true
	
	var grind_rail: Rail = grind_ray.get_collider(0).get_parent()
	
	rail_grind_node = find_nearest_rail_follower(grind_rail)
	rail_grind_node.detach = false
	
	# determine grind direction
	var player_forward = -player.global_transform.basis.z.normalized()
	var direction_to_rail_start: Vector3 = get_direction_to_rail_start(grind_rail)
	var dot_product: float = player_forward.dot(direction_to_rail_start)
	var is_moving_towards_rail_start: bool = dot_product > 0.0
	rail_grind_node.progress_direction = -1.0 if is_moving_towards_rail_start else 1.0
	
	# place player on closest offset
	var closest_offset = grind_rail.curve.get_closest_offset(player.global_position)
	rail_grind_node.progress = closest_offset
	

	var path_forward: Vector3 = -rail_grind_node.global_transform.basis.z
	var travel_dir := (path_forward * rail_grind_node.progress_direction).normalized()
	target_yaw = atan2(-travel_dir.x, -travel_dir.z)

	# Update players rotation and position
	rotate_player_for_grinding()
	emit_signal("toggle_grinding", true)
	
func rotate_player_for_grinding():
	# Turn player 45 degrees to the rail
	var path_forward: Vector3 = -rail_grind_node.global_transform.basis.z
	var perpendicular = path_forward.rotated(Vector3.UP, PI / 2)
	
	var model_scale := player_model.scale
	player_model.global_transform = player_model.global_transform.looking_at(player_model.global_position + perpendicular, Vector3.UP)
	# must reset model_scale if it is not 1.0 by default 
	player_model.scale = model_scale

	var board_scale := skateboard_model.scale
	skateboard_model.global_transform = skateboard_model.global_transform.looking_at(skateboard_model.global_position + perpendicular, Vector3.UP)
	skateboard_model.scale = board_scale
	
func update_player_camera():
	var path_forward: Vector3 = -rail_grind_node.global_transform.basis.z
	var travel_dir := (path_forward * rail_grind_node.progress_direction).normalized()
	target_yaw = atan2(-travel_dir.x, -travel_dir.z)
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, target_yaw, 0.08)

func update_player_position():
	player.global_position = rail_grind_node.global_position
 
func detach_from_rail():
	can_grind = false
	grinding = false
	rail_grind_node.chosen = false
	rail_grind_node.detach = false
	player_model.transform = initial_player_model_transform
	skateboard_model.transform = initial_skateboard_model_transform
	camera_pivot.rotation = initial_camera_pivot_rotation
	emit_signal("toggle_grinding", false)
	
	# reset can_grind after timeout
	await get_tree().create_timer(1.0).timeout
	can_grind = true
 
func get_direction_to_rail_start(grind_rail: Rail) -> Vector3:
	var local_rail_start_pos: Vector3 = grind_rail.curve.get_point_position(0)
	var global_rail_start_pos: Vector3 = grind_rail.to_global(local_rail_start_pos)
	var direction_to_rail_start = player.global_position.direction_to(global_rail_start_pos)
	return direction_to_rail_start
 
func find_nearest_rail_follower(rail_node) -> RailFollower:
	var nearest_node = null
	var min_distance = INF
	for node in rail_node.get_children():
		if node.is_in_group("rail_follower"):
			var distance = player.global_position.distance_to(node.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_node = node
				
	return nearest_node as RailFollower
