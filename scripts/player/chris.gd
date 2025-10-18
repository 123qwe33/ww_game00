extends NPC

const STOP_DISTANCE: float = 200.0

var player: Character = null
var has_reached_player: bool = false

func _ready():
	super._ready()
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("Chris: Could not find player in scene")

func _physics_process(delta):
	# Only move if we have a valid player reference and haven't reached them yet
	if player and not has_reached_player:
		var distance_to_player = global_position.distance_to(player.global_position)

		# Walk left if we're too far from the player
		if distance_to_player > STOP_DISTANCE:
			movement_direction = -1.0
		else:
			# Reached the player - stop forever and show dialog
			movement_direction = 0.0
			has_reached_player = true
			_show_dialog_when_ready()
	else:
		movement_direction = 0.0

	# Let Character handle all the physics, gravity, animations, etc.
	super._physics_process(delta)

func _show_dialog_when_ready():
	"""Wait for dialog to be ready, then show it"""
	# Wait until dialog_ready flag is set
	while not dialog_ready:
		await get_tree().process_frame

	if dialog_box:
		dialog_box.show_multiple_dialogs([
			"Hey! I finally caught up to you!",
			"I've been chasing you for a while!",
			"Nice to see you again!"
		], ["p1_interact", "p2_interact"], self, true)  # true = drops item when closed
	else:
		push_error("Chris: Dialog box is null when trying to show dialog!")
