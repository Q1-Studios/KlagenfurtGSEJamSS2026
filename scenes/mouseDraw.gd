extends Node2D


var mousePositions: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	
	mousePositions.append(event.position)
	queue_redraw()

func _draw() -> void:
	for coord in mousePositions:
		draw_circle(coord, 10, Color.RED)
		
