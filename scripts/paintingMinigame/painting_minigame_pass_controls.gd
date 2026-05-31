extends Node3D

signal gameOver
signal passPoints(pointsReached: int)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	for child in get_children():
		if child is SubViewport:
			child.push_input(event)

func _on_node_2d_drawing_phase_over(pointsReached: int) -> void:
	print("recieve points from 2d:", pointsReached)
	gameOver.emit()
	passPoints.emit(pointsReached)
	print("emit from 3d minigame to main: ", pointsReached)
