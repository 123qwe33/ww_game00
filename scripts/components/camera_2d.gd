# Camera2D.gd
extends Camera2D

@export var target_node_path: NodePath # Assign player node path in inspector
@export var smooth_speed = 5.0
@export var max_vertical_follow = 800.0 # Maximum vertical distance camera will follow player down
@export var vertical_offset = -50.0 # Offset to keep player below the center
var target: Node2D
var initial_vertical_position = 0.0

func _ready():
	if target_node_path:
		target = get_node_or_null(target_node_path)
	if target == null:
		print("Camera target not found!")
	else:
		# Store the initial vertical position as reference
		initial_vertical_position = target.global_position.y


func _process(delta):
	if target:
		var target_position = target.global_position

		# Limit how far down the camera will follow
		var max_y_position = initial_vertical_position + max_vertical_follow
		if target_position.y > max_y_position:
			target_position.y = max_y_position

		# Apply vertical offset to the target position
		target_position.y += vertical_offset
		global_position = global_position.lerp(Vector2(target_position.x, target_position.y), delta * smooth_speed)

		# Optional: Set camera limits if your level has boundaries
		# limit_left = 0
		# limit_top = 0
		# limit_right = 2000 # Example map width
		# limit_bottom = max_y_position + 300 # Prevent camera from going too far down
