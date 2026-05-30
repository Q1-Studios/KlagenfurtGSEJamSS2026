extends CharacterBody3D
@onready var movementController := %MovementController
@onready var grindingController := %GrindingController
@onready var trick_mode_controller := %TrickModeController
@onready var grind_update_timer = %GrindUpdateSprayCanTimer
@onready var healthBar = $SubViewport/ProgressBar

@export_category("Spray Can")
@export var max_spray_can_amount: float = 100.0
@export_range(1.0, 100.0, 1.0) var spray_can_grind_reward: float = 8.0

var spray_can_amount: float = 0.0

signal spray_can_amount_updated(amount: float)

func _ready() -> void:
	spray_can_amount_updated.emit(spray_can_amount)
	healthBar.value = 0
	healthBar.max_value = max_spray_can_amount
	spray_can_amount = 0
	trick_mode_controller.instanciate(self)

func _physics_process(_delta: float) -> void:
	grindingController.handle_grinding()
	movementController.handle_movement(self)
	move_and_slide()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debugButtonTODORemoveLater"):
		trick_mode_controller.create_goal_sequence()

func _on_toggle_grinding(_is_grinding: bool) -> void:
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
