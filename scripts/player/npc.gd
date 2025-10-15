extends Character
class_name NPC

var movement_direction: float = 0.0

func _ready():
	super._ready()
	# NPCs don't use player input
	input_enabled = false

# Override to return NPC-controlled direction instead of input
func get_movement_direction() -> float:
	return movement_direction
