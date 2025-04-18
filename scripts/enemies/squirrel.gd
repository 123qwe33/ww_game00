extends CharacterBody2D

@onready var sprite = $Sprite2D # Or $AnimatedSprite2D

const SPEED = 50.0 # How fast the squirrel moves
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1 # 1 for right, -1 for left

# Optional: Timer for changing direction
@onready var direction_timer = $DirectionTimer

func _ready():
	# If using a Timer node named DirectionTimer:
	# Set it to wait a random time before the first direction change
	# direction_timer.wait_time = randf_range(2.0, 5.0)
	# direction_timer.start()
	pass # Placeholder if not using Timer yet

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Move in the current direction
	velocity.x = direction * SPEED

	# Flip sprite based on direction
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

	# Move the squirrel
	move_and_slide()

	# Simple way to turn around at edges (requires checking if still on floor after move)
	# Or if hitting a wall
	if is_on_floor():
		var floor_check_point = sign(velocity.x) * (sprite.get_rect().size.x / 2 + 5) # Check just ahead of the squirrel
		var check_pos = Vector2(floor_check_point, sprite.get_rect().size.y / 2 + 5) # Check just below the front edge
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = global_position + check_pos
		query.collide_with_areas = false
		query.collide_with_bodies = true
		var result = space_state.intersect_point(query)

		# If there's no floor ahead OR if the squirrel bumped a wall, turn around
		if result.is_empty() or is_on_wall():
			 # Need to check if the point check worked
			 # Or just is_on_wall() is simpler if your level has walls
			if is_on_wall(): # Simpler check
				direction *= -1
				# Optional: Reset timer if using one
				# direction_timer.wait_time = randf_range(2.0, 5.0)
				# direction_timer.start()


# Optional: Function called when DirectionTimer times out
# func _on_direction_timer_timeout():
#     direction *= -1 # Reverse direction
#     # Set a new random wait time
#     direction_timer.wait_time = randf_range(2.0, 5.0)
#     direction_timer.start() # Restart timer
