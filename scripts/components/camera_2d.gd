# Camera2D.gd
extends Camera2D

@export var target_node_path: NodePath # Assign player node path in inspector
@export var smooth_speed = 5.0

var target: Node2D

func _ready():
	if target_node_path:
		target = get_node_or_null(target_node_path)
	if target == null:
		print("Camera target not found!")


func _process(delta):
	if target:
		# Smoothly interpolate camera's global position towards the target's global position
		global_position = global_position.lerp(target.global_position, delta * smooth_speed)

		# Optional: Clamp camera limits if needed
		# limit_left = 0
		# limit_top = 0
		# limit_right = 2000 # Example map width
		# limit_bottom = 1000 # Example map height
