extends Area2D

# Signal emitted when a player in range presses their interact action
signal interact_pressed(player: Character)

# Signal emitted when a player enters interaction range
signal player_entered(player: Character)

# Signal emitted when a player exits interaction range
signal player_exited(player: Character)

# Signal emitted when a player tries to interact but doesn't have required item
signal interaction_failed(player: Character, required_items: Array[String])

const INTERACTION_RANGE: float = 200.0

# Array of item IDs required to interact. Empty array = no requirements
@export var required_items: Array[String] = []

# Tracks all players currently in range
var players_in_range: Array[Character] = []

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	# Check if the body is a player character
	if body.is_in_group("player") and body is Character:
		players_in_range.append(body)
		player_entered.emit(body)

func _on_body_exited(body: Node2D):
	# Remove player from range tracking
	if body in players_in_range:
		players_in_range.erase(body)
		player_exited.emit(body)

func _unhandled_input(event):
	# Check if any player in range pressed their interact action
	for player in players_in_range:
		if player and "input_prefix" in player:
			var interact_action = player.input_prefix + "_interact"

			# Check if this action exists in the input map
			if InputMap.has_action(interact_action):
				if event.is_action_pressed(interact_action):
					# Check if player meets item requirements
					if required_items.size() > 0:
						var has_required_item = false
						if "current_held_item" in player and player.current_held_item != "":
							has_required_item = player.current_held_item in required_items

						if not has_required_item:
							# Player doesn't have required item
							interaction_failed.emit(player, required_items)
							get_viewport().set_input_as_handled()
							return

					# Either no requirements or player has required item
					interact_pressed.emit(player)
					get_viewport().set_input_as_handled()
					return
