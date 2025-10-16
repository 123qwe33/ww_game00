extends NPC

const STOP_DISTANCE: float = 200.0

var player: Character = null

func _ready():
	super._ready()
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("Chris: Could not find player in scene")

func _physics_process(delta):
	# Only move if we have a valid player reference
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)

		# Walk left if we're too far from the player
		if distance_to_player > STOP_DISTANCE:
			movement_direction = -1.0
		else:
			movement_direction = 0.0
	else:
		movement_direction = 0.0

	# Let Character handle all the physics, gravity, animations, etc.
	super._physics_process(delta)
