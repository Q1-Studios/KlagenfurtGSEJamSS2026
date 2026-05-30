class_name Bert
extends CharacterBody3D
@onready var movementController := %MovementController
@onready var grindingController := %GrindingController
@onready var trick_mode_controller := %TrickModeController
@onready var wrong_input_timer := %WrongInputTimer
@onready var grind_update_timer = %GrindUpdateSprayCanTimer
@onready var healthBar = $SprayFuelSubviewPort/ProgressBar

@export_category("Spray Can")
@export var max_spray_can_amount: float = 100.0
@export_range(1.0, 100.0, 1.0) var spray_can_grind_reward: float = 8.0
@export var spray_color: Color = Color.RED
@export var spray_brush_radius: float = 0.5
@export var spray_drain_per_second: float = 20.0

var spray_can_amount: float = 0.0

signal spray_can_amount_updated(amount: float)

var slow_mo = false
var slow_mo_factor: float = 4.0
var is_grinding: bool = false

func _ready() -> void:
	spray_can_amount_updated.emit(spray_can_amount)
	healthBar.value = 0
	healthBar.max_value = max_spray_can_amount
	spray_can_amount = 0
	trick_mode_controller.instanciate(self, slow_mo_factor)

func _physics_process(delta: float) -> void:
	grindingController.handle_grinding()
	movementController.handle_movement(self, delta)
	move_and_slide()
	
func _process(delta: float) -> void:
	if _can_spray_paint():
		FloorPainter.paint(global_position, spray_color, spray_brush_radius)
		spray_can_amount = max(0.0, spray_can_amount - spray_drain_per_second * delta)
		spray_can_amount_updated.emit(spray_can_amount)
		_update_fuel_ui()

	if Input.is_action_just_pressed("enter_trick_mode"):
		trick_mode_controller.create_goal_sequence()

func _can_spray_paint() -> bool:
	return Input.is_action_pressed("spray") and !is_grinding and is_on_floor() and spray_can_amount > 0.0

func _on_toggle_grinding(_is_grinding: bool) -> void:
	is_grinding = _is_grinding
	if _is_grinding:
		grind_update_timer.start()
	else:
		grind_update_timer.stop()

func _on_grind_update_graffiti_timer_timeout() -> void:
	# update graffiti fuel gained through grinding
	var new_amount: float = min(spray_can_amount + spray_can_grind_reward, max_spray_can_amount)
	spray_can_amount = new_amount
	spray_can_amount_updated.emit(spray_can_amount)
	_update_fuel_ui()

func _update_fuel_ui() -> void:
	healthBar.value = spray_can_amount

func _enter_slow_mode():
	Engine.time_scale = 1.0 / slow_mo_factor 
	# trickAnimationPlayer.speed_scale = slow_mo_factor 
	# animationPlayerForStuffNotRelatedToTricks.speed_scale = 1.0 
	trick_mode_controller.toggle_slow_mo(true)
	wrong_input_timer.wait_time /= slow_mo_factor

func _exit_slow_mode():
	Engine.time_scale = 1.0
	# trickAnimationPlayer.speed_scale = 1.0
	# animationPlayerForStuffNotRelatedToTricks.speed_scale = 1.0 
	trick_mode_controller.toggle_slow_mo(false)
	wrong_input_timer.wait_time *= slow_mo_factor
	
func enter_trick_mode():
	_enter_slow_mode()
	trick_mode_controller.create_goal_sequence()

func leave_trick_mode():
	_exit_slow_mode()
	trick_mode_controller.deactivate()

func _on_movement_controller_landed() -> void:
	leave_trick_mode()
	
func _on_trick_mode_controller_leave_trick_mode() -> void:
	_exit_slow_mode()
