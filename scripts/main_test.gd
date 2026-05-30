extends Node3D

var playerPoints = 0
@onready var pointsHUD = $HUD/PointsAmount
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sealskater_graffiti_fuel_updated(amount: float) -> void:
	print("Updated spray can amount trough grinding: {0}".format([amount]))


func _on_sealskater_spray_can_amount_consumed_for_points(points: float) -> void:
	playerPoints += points
	print("Player Points: ", playerPoints)
	pointsHUD.text = str(int(playerPoints))

func _on_node_2d_pass_points(points: float) -> void:
	playerPoints += points
	print("Player Points: ", playerPoints)
	pointsHUD.text = str(int(playerPoints))


func instantiateMinigame() -> void:
	pass
