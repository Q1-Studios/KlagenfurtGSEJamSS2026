extends CharacterBody3D
@onready var movementController := %MovementController
@onready var grindingController := %GrindingController


func _physics_process(delta: float) -> void:
	grindingController.handle_grinding()
	movementController.handle_movement(self)
	move_and_slide()
