extends CharacterBody3D
@onready var movementController := %MovementController
@onready var grindingController := %GrindingController
@onready var grind_graffiti_update_timer = %GrindUpdateGraffitiTimer

@export var max_graffiti_fuel_amount: float = 100.0
@export_range(1.0, 100.0, 1.0) var graffiti_grind_reward: float = 3.0

var graffiti_fuel_amount: float = max_graffiti_fuel_amount

signal graffiti_fuel_updated(amount: float)

func _ready() -> void:
	graffiti_fuel_updated.emit(graffiti_fuel_amount)

func _physics_process(_delta: float) -> void:
	grindingController.handle_grinding()
	movementController.handle_movement(self)
	move_and_slide()

func _on_toggle_grinding(_is_grinding: bool) -> void:
	if _is_grinding:
		grind_graffiti_update_timer.start()
	else:
		grind_graffiti_update_timer.stop()


func _on_grind_update_graffiti_timer_timeout() -> void:
	# update graffiti fuel gained through grinding
	var new_amount: float = min(graffiti_fuel_amount + graffiti_grind_reward, max_graffiti_fuel_amount)
	graffiti_fuel_amount = new_amount
	graffiti_fuel_updated.emit(graffiti_fuel_amount)
