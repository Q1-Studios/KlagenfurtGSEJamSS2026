extends Path3D
class_name Rail

@export var rail_follower = preload("res://scenes/rail_follower.tscn")
 
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(create_rail_follower())
	
func _process(_delta):
	pass
	
func create_rail_follower() -> RailFollower:
	var instance = rail_follower.instantiate()
	instance.loop = false
	return instance
