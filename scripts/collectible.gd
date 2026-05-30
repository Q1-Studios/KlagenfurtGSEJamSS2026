extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if is_instance_of(body, Bert):
		body.enter_trick_mode()
		queue_free()
