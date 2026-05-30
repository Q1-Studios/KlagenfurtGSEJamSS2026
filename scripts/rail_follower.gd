extends PathFollow3D
class_name RailFollower

const UPPER_PROGRESS_BOUND: float = 0.999
const LOWER_PROGRESS_BOUND: float = 0.002
 
@onready var origin_point = null
@onready var chosen = false
@onready var detach = false

@export var grind_speed : float = 15.0
@export var progress_direction: float = 1.0

var grinding: bool = false
 
# Called when the node enters the scene tree for the first time.
func _ready():
	origin_point = progress
 
func _process(delta):
	if grinding:
		progress += (grind_speed * delta * progress_direction)
		
		var current_progress_ratio = get_progress_ratio()
		if current_progress_ratio <= LOWER_PROGRESS_BOUND or current_progress_ratio >= UPPER_PROGRESS_BOUND:
			detach = true
			grinding = false
			
	if chosen:
		grinding = true
	else:
		grinding = false
		progress = origin_point
