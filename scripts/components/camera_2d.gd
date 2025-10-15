# Camera2D.gd
extends Camera2D

@export var smooth_speed = 5.0
@export var max_vertical_follow = 800.0 # Maximum vertical distance camera will follow player down
@export var vertical_offset = -50.0 # Offset to keep player below the center

# Zoom settings
@export var min_zoom = 1.0 # Fully zoomed in
@export var max_zoom = 0.4 # Fully zoomed out (smaller = more zoomed out in Godot)
@export var zoom_margin = 200.0 # Padding in pixels around players
@export var zoom_smooth_speed = 3.0 # Speed of zoom transitions

var initial_vertical_position = 0.0
var players: Array[Node2D] = []

func _ready():
	# Find initial vertical position from first player
	players = get_players()
	if players.size() > 0:
		initial_vertical_position = players[0].global_position.y
	else:
		print("Camera: No players found in 'player' group!")


func _process(delta):
	# Get all active players
	players = get_players()

	if players.size() == 0:
		return

	# Calculate center point of all players
	var center_position = calculate_center_position()

	# Calculate required zoom to fit all players
	var target_zoom = calculate_target_zoom()

	# Limit how far down the camera will follow
	var max_y_position = initial_vertical_position + max_vertical_follow
	if center_position.y > max_y_position:
		center_position.y = max_y_position

	# Apply vertical offset to the target position
	center_position.y += vertical_offset

	# Smoothly move camera to center position
	global_position = global_position.lerp(center_position, delta * smooth_speed)

	# Smoothly adjust zoom
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), delta * zoom_smooth_speed)


# Get all nodes in the player group
func get_players() -> Array[Node2D]:
	var player_nodes: Array[Node2D] = []
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D:
			player_nodes.append(node as Node2D)
	return player_nodes


# Calculate the center position of all players
func calculate_center_position() -> Vector2:
	if players.size() == 0:
		return global_position

	var sum_position = Vector2.ZERO
	for player in players:
		sum_position += player.global_position

	return sum_position / players.size()


# Calculate zoom level needed to fit all players on screen
func calculate_target_zoom() -> float:
	if players.size() <= 1:
		return min_zoom # Default zoom for single player

	# Find bounding box containing all players
	var min_pos = players[0].global_position
	var max_pos = players[0].global_position

	for player in players:
		var pos = player.global_position
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)

	# Calculate required space with margin
	var required_width = (max_pos.x - min_pos.x) + zoom_margin * 2
	var required_height = (max_pos.y - min_pos.y) + zoom_margin * 2

	# Get viewport size
	var viewport_size = get_viewport_rect().size

	# Calculate zoom needed for width and height
	var zoom_for_width = viewport_size.x / required_width
	var zoom_for_height = viewport_size.y / required_height

	# Use the smaller zoom to ensure both players fit
	var required_zoom = min(zoom_for_width, zoom_for_height)

	# Clamp between min and max zoom
	return clamp(required_zoom, max_zoom, min_zoom)
