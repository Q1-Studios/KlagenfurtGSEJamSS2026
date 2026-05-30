extends CPUParticles2D

@onready var currentFill = $"..".value
@onready var barPosition = $"..".global_position
@onready var barSize = $"..".size
@onready var barHeight = barSize.y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currentFill = $"..".value
	barPosition = $"..".global_position
	barSize = $"..".size
	barHeight = barSize.y
	calcPositionOffset()
	pass


func calcPositionOffset() -> void:
	$".".global_position.x = (barPosition.x -25)
	$".".global_position.y = (barPosition.y - currentFill * 2.2)
