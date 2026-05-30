extends Node2D


var mousePositions: Array = []
var markerContainer: Node2D
var markerList: Array = []
var marker2DArrayVector = PackedVector2Array()
var markerListBoolean: Array[bool]
const DISTANCE_THRESHOLD: int = 25
var totalDistancePoints: float = 0
var previousCursorPosition: Vector2 
var totalDistanceCursor: float = 0
var markerBoolean: Array[bool] = []
var allPointsReached: bool = false
var rng = RandomNumberGenerator.new()
var weights = PackedFloat32Array([2, 1, 1, 1])
@onready var lineSprite = $FollowLine

@onready var cursorImg = $Cursor

var bert = load("res://assets/paintingMinigame/snek.jpg")
var q1 = load("res://assets/paintingMinigame/q1.jpg")
var smile = load("res://assets/paintingMinigame/smileSisterSadisticSurprise.jpg")
var schlauerStudent = load("res://assets/paintingMinigame/schlauerStudent.jpg")


var imgDictionary = {
	"bert": [
		Vector2(788.0,369.0),
		Vector2(794.0,460.0),
		Vector2(810.999938964844,299.0),
		Vector2(917.0,276.000030517578),
		Vector2(1057.0,272.0),
		Vector2(1149.0,360.000030517578),
		Vector2(1129.0,470.000061035156),
		Vector2(1004.0,504.0),
		Vector2(897.0,503.0),
		Vector2(797.999938964844,589.0),
		Vector2(794.0,691.0),
		Vector2(873.0,767.0),
		Vector2(1050.0,768.0),
		Vector2(1098.0,636.0),
		Vector2(884.0,555.0),
		Vector2(1027.0,543.0)
		],
	"q1" : [
		Vector2(723.0,370.000030517578),
		Vector2(739.0,520.0),
		Vector2(803.999938964844,366.0),
		Vector2(879.0,336.0),
		Vector2(928.0,405.0),
		Vector2(923.999938964844,476.0),
		Vector2(827.0,508.0),
		Vector2(776.0,431.0),
		Vector2(927.0,514.0),
		Vector2(1042.0,566.0),
		Vector2(1129.0,621.0),
		Vector2(1264.0,635.0),
		Vector2(864.0,527.0),
		Vector2(916.0,603.0),
		Vector2(1042.0,689.0),
		Vector2(1167.0,739.0)
		],
	"smile": [
		Vector2(713.0,512.0),
		Vector2(762.0,426.0),
		Vector2(900.999938964844,368.999969482422),
		Vector2(1058.0,399.999969482422),
		Vector2(1145.0,497.0),
		Vector2(1123.0,624.0),
		Vector2(1012.0,701.0),
		Vector2(832.0,679.0),
		Vector2(734.0,609.0),
		Vector2(849.0,479.0),
		Vector2(1012.0,479.0),
		Vector2(879.0,583.0),
		Vector2(927.0,609.0),
		Vector2(988.0,583.0)
		],
	"schlauerStudent":[
		Vector2(700.999877929688,514.0),
		Vector2(749.999938964844,428.0),
		Vector2(888.999877929688,370.999969482422),
		Vector2(1046.0,401.999969482422),
		Vector2(1146.0,487.0),
		Vector2(1124.0,635.0),
		Vector2(1000.0,712.0),
		Vector2(811.0,703.0),
		Vector2(729.0,635.0),
		Vector2(846.0,471.0),
		Vector2(1026.0,464.0),
		Vector2(880.0,626.0),
		Vector2(937.0,658.0),
		Vector2(1000.0,611.0),
		Vector2(1146.0,552.0),
		Vector2(1224.0,471.0),
		Vector2(1259.0,588.0),
		Vector2(1215.0,681.0),
		Vector2(1083.0,712.0),
		Vector2(1071.0,616.0),
		Vector2(1100.0,577.0)
		]
	}

func prepareMarkerPoints() -> void:
	var currentImg = imgDictionary.keys()[rng.rand_weighted(weights)]
	print("Current Image to trace: ", currentImg)
	markerList = imgDictionary.get(currentImg)
	for each in markerList:
		marker2DArrayVector.append(each)
	markerListBoolean.resize(markerList.size())
	markerListBoolean.fill(false)
	previousCursorPosition = marker2DArrayVector[0]
	
	match currentImg:
		"bert":
			$FollowLine.texture = bert
		"q1":
			$FollowLine.texture = q1
		"smile":
			$FollowLine.texture = smile
		"schlauerStudent":
			$FollowLine.texture = schlauerStudent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prepareMarkerPoints()
	calctotalDistancePoints()	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	#if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) || totalDistanceCursor > totalDistancePoints*2 || allPointsReached:
		#return
	if not Input.is_action_pressed("LMB") || totalDistanceCursor > totalDistancePoints*2 || allPointsReached:
		return
	
	trackCursorDistance()
	print("test ",typeof(event))
	if (typeof(event) != typeof(InputEventJoypadButton)):
		mousePositions.append(event.global_position)
	else:
		mousePositions.append(cursorImg.global_position)
	queue_redraw()
	
	if (typeof(event) != typeof(InputEventJoypadButton)):
		_checkPointProximity(event.global_position)
	else:
		_checkPointProximity(cursorImg.global_position)
	print("cursor distance: ", totalDistanceCursor, "total distance allowed: ", totalDistancePoints)
	

func _draw() -> void:
	for coord in mousePositions:
		draw_circle(coord, 10, Color.RED)


func _checkPointProximity(position) -> void:
	for each in marker2DArrayVector:
		if position.distance_to(each) < DISTANCE_THRESHOLD:
			print("Hit marker at: ", each)
			var index = markerList.find(each)
			markerListBoolean[index] = true
			printBooleans()
			checkAllPoints()

func checkAllPoints() -> void:
	if markerListBoolean.find(false) == -1:
		allPointsReached = true


func printBooleans() -> void:
	var i = 0
	for x in markerListBoolean.size():
		print("position ", i, ": ", markerListBoolean[i])
		i = i+1

func calctotalDistancePoints() -> void:
	var i = 0
	for x in marker2DArrayVector.size()-1:
		totalDistancePoints += marker2DArrayVector[i].distance_to(marker2DArrayVector[i+1])
		i += 1
		
	
func trackCursorDistance() -> void:
	var mousePosition = get_global_mouse_position()
	totalDistanceCursor += (mousePosition - previousCursorPosition).length()
	print(totalDistanceCursor)
	previousCursorPosition = mousePosition
	pass
