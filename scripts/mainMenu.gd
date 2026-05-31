extends Node3D

@onready var leaderboard_ppl_label = %LeaderboardPPL
@onready var username_input = %username

func _ready() -> void:
	username_input.text = GameManger.username

func _enter_tree() -> void:
	ScoreManager.leaderboard_updated.connect(_update_leaderboard)

@onready var tutorialSprite = $Sprite2D
func _input(event: InputEvent) -> void:
	if  Input.is_key_pressed(KEY_ESCAPE):
		tutorialSprite.hide()

func _update_leaderboard() -> void:
	var score_board = ScoreManager.scoreboard["scores"]
	var leaderboard_text = ""
	var displayed_score_count = min(5, score_board.size())
	
	if displayed_score_count <= 1:
		return;
	
	for i in range(displayed_score_count):
		leaderboard_text += "%d) %s: %d\n" % [i+1, score_board[i]["name"], round(score_board[i]["score"])]
	if (GameManger.last_score >= 0):
		leaderboard_text += "%s: %d\n" % ["you", round(GameManger.last_score)]
	leaderboard_ppl_label.text = leaderboard_text
		
func _on_play_button_pressed() -> void:
	GameManger.is_sandbox = false
	if username_input.text == "":
		username_input.text = GameManger.default_username
	
	GameManger.username = username_input.text
	get_tree().change_scene_to_file("res://scenes/GameLevel.tscn")
	

# please change later for sandbox mode, this is currently pointing to standard game

func _on_sandbox_button_pressed() -> void:
	GameManger.is_sandbox = true
	if username_input.text == "":
		username_input.text = GameManger.default_username
	
	GameManger.username = username_input.text
	get_tree().change_scene_to_file("res://scenes/GameLevel.tscn")


func _on_tutorial_pressed() -> void:
	tutorialSprite.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
