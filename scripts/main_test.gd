extends Node3D

var playerPoints = 0
@onready var pointsHUD = $HUD/PointsAmount
@onready var game_timer = %GameTimer

var sandbox = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sandbox = GameManger.is_sandbox
	if not sandbox:
		game_timer.start(GameManger.game_time)
		
	

func _input(event: InputEvent) -> void:
	if  Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/meu3D.tscn")


func _on_sealskater_graffiti_fuel_updated(amount: float) -> void:
	print("Updated spray can amount trough grinding: {0}".format([amount]))


func _on_sealskater_spray_can_amount_consumed_for_points(points: float) -> void:
	playerPoints += points
	pointsHUD.text = str(int(playerPoints))

func _on_node_2d_pass_points(pointsReached: int) -> void:
	print("parent in 3d recieved points: ", pointsReached)
	playerPoints += pointsReached
	pointsHUD.text = str(int(playerPoints))


func _on_game_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/meu3D.tscn")
	ScoreManager.add_score("Guest", playerPoints)
