extends Node3D

@onready var minigameScene: PackedScene = load("res://scenes/paintingMinigame3D.tscn")
var tempScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spawnSceneDeleteLater"):
		addMinigameScene()
	pass

func addMinigameScene() -> void:
	tempScene = minigameScene.instantiate()
	add_child(tempScene)
	tempScene.gameOver.connect(removeMinigameScene)

func removeMinigameScene() -> void:
	remove_child(tempScene)


func _on_node_3d_game_over() -> void:
	print("i am here")
	removeMinigameScene()
