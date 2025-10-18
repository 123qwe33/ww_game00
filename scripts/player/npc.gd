extends Character
class_name NPC

const DialogBox = preload("res://scenes/components/dialog_box.tscn")
var dialog_box: Control = null
var dialog_ready: bool = false

var movement_direction: float = 0.0

func _ready():
	super._ready()
	# NPCs don't use player input
	input_enabled = false
	# Setup dialog box for all NPCs
	_setup_dialog_box()

func _setup_dialog_box():
	"""Setup dialog box asynchronously"""
	dialog_box = DialogBox.instantiate()
	add_child(dialog_box)
	# Wait one frame for the node to be fully initialized
	await get_tree().process_frame
	dialog_ready = true

# Override to return NPC-controlled direction instead of input
func get_movement_direction() -> float:
	return movement_direction
