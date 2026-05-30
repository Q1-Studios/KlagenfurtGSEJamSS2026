extends Node2D


var mousePositions: Array = []
var markerContainer: Node2D
var markerList: Array = []
var markerListBoolean: Array[bool]
const DISTANCE_THRESHOLD: int = 40
var totalDistancePoints: float = 0
var previousCursorPosition: Vector2 
var totalDistanceCursor: float = 0
var markerBoolean: Array[bool] = []
var allPointsReached: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	markerList = get_node("markerContainer").get_children()
	for each in markerList:
		print("Vector2(",each.global_position.x,",",each.global_position.y,"),")
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
