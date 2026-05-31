extends Node3D

@onready var tutorialSprite = $Sprite2D
func _input(event: InputEvent) -> void:
	if  Input.is_key_pressed(KEY_ESCAPE):
		tutorialSprite.hide()
		
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# please change later for sandbox mode, this is currently pointing to standard game

func _on_sandbox_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_tutorial_pressed() -> void:
	tutorialSprite.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
