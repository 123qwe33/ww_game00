extends Character
class_name NPC

const DialogBox = preload("res://scenes/components/dialog_box.tscn")
var dialog_box: Control = null

var movement_direction: float = 0.0

func _ready():
	super._ready()
	# NPCs don't use player input
	input_enabled = false

# Override to return NPC-controlled direction instead of input
func get_movement_direction() -> float:
	return movement_direction
