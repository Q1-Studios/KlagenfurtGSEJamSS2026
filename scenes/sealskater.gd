extends CharacterBody3D
@onready var movementController := %MovementController


func _physics_process(delta: float) -> void:
	movementController.handle_movement(self)
	move_and_slide()
