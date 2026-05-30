extends Node2D


var mousePositions: Array = []
var markerContainer: Node2D
var markerList: Array = []
var marker2DArrayVector = PackedVector2Array()
var markerListBoolean: Array[bool]
const DISTANCE_THRESHOLD: int = 75
var totalDistancePoints: float = 0
var previousCursorPosition: Vector2 
var totalDistanceCursor: float = 0
var markerBoolean: Array[bool] = []
var allPointsReached: bool = false
var rng = RandomNumberGenerator.new()
var weights = PackedFloat32Array([2,1,1,1])
@onready var lineSprite = $FollowLine

@onready var cursorImg = $Cursor

var bert = load("res://assets/paintingMinigame/snek.jpg")
var q1 = load("res://assets/paintingMinigame/q1.jpg")
var smile = load("res://assets/paintingMinigame/smileSisterSadisticSurprise.jpg")
var schlauerStudent = load("res://assets/paintingMinigame/schlauerStudent.jpg")

var canDraw: bool = true
@onready var timer: Timer = $Timer
var default_font : Font = ThemeDB.fallback_font

var imgDictionary = {
	"bert": [
		Vector2(802.0,301.000030517578),
		Vector2(1129.0,298.0),
		Vector2(1095.0,757.0),
		Vector2(790.0,759.0)
	], 
	"q1": [
		Vector2(793.0,730.0),
		Vector2(936.0,365.000030517578),
		Vector2(1057.0,727.0),
		Vector2(712.999938964844,528.0),
		Vector2(1185.0,540.0),
	],
	"schlauerStudent": [
		Vector2(691.0,544.0),
		Vector2(758.0,376.0),
		Vector2(920.0,327.000030517578),
		Vector2(1079.0,367.0),
		Vector2(1148.0,552.0),
		Vector2(1103.0,719.0),
		Vector2(934.0,801.0),
		Vector2(761.0,711.0)	
		],
	"smile": [
		Vector2(715.0,574.0),
		Vector2(715.0,486.0),
		Vector2(1069.0,491.0),
		Vector2(1070.0,420.000030517578),
		Vector2(1213.0,530.0),
		Vector2(1075.0,664.0),
		Vector2(1071.0,584.0)
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
	timer.start()
	setCursorPosition()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(timer.time_left)
	pass


func _input(event: InputEvent) -> void:
	#if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) || totalDistanceCursor > totalDistancePoints*2 || allPointsReached:
		#return
	if not Input.is_action_pressed("LMB") || totalDistanceCursor > totalDistancePoints*2 || allPointsReached || !canDraw:
		return
	
	trackCursorDistance()
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


# this is for drawin the circles at where user input is being recorded
func _draw() -> void:
	
	var i = 0
	var j = 0
	for each in marker2DArrayVector:
		draw_string(default_font, each, str(j), HORIZONTAL_ALIGNMENT_CENTER, 90, 22)
		j += 1
	if mousePositions.size() == 1:
		pass
	else:
		for coord in mousePositions:
			draw_line(mousePositions[i-1], mousePositions[i], Color.RED, 10)
			i += 1
		 
		


func _checkPointProximity(position) -> void:
	for each in marker2DArrayVector:
		if position.distance_to(each) < DISTANCE_THRESHOLD:
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
	previousCursorPosition = mousePosition
	pass


func _on_timer_timeout() -> void:
	canDraw = false

func setCursorPosition() -> void:
	cursorImg.global_position = Vector2(1980/2, 1080/2)
