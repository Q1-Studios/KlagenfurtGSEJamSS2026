extends Node3D

@onready var minigameScene: PackedScene = load("res://scenes/paintingMinigame3D.tscn")
var tempScene

signal passPointsToParentSignal
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
	tempScene.passPoints.connect(passPointsToParent)

func removeMinigameScene() -> void:
	remove_child(tempScene)

func passPointsToParent(pointsReached: int) -> void:
	print("recieved from 3d minigame in main: ", pointsReached)
	passPointsToParentSignal.emit(pointsReached)
	print("sending to parent in main: ", pointsReached)
	
