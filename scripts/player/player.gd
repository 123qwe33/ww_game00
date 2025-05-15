extends CharacterBody2D

# Add to "player" group so squirrels can detect us
func _ready():
	add_to_group("player")

@onready var sprite = $AnimatedSprite2D

# Death settings
const DEATH_Y_THRESHOLD = 2000  # How far the player can fall before dying

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const AIR_THRESHOLD = 0.15  # Time in seconds to ignore brief air states
const PUSH_FORCE = 100.0 # Adjust this value later!

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var air_time = 0.0  # Tracks how long player has been in the air

func _physics_process(delta):
	# Check for death by falling
	check_fall_death()
	
	# Track air time and handle gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		air_time += delta
	else:
		air_time = 0.0

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		air_time = AIR_THRESHOLD  # Immediately consider this a real jump

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")

	# Flip the sprite based on direction
	if direction > 0:
		sprite.flip_h = false # Facing right (assuming default sprite faces right)
	elif direction < 0:
		sprite.flip_h = true  # Facing left
		# Note: If direction is 0, the sprite keeps its last orientation.

	# Set velocity based on direction
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) # Simple friction/stop
		
	# Handle animations based on state
	if not is_on_floor() and air_time >= AIR_THRESHOLD:
		# Only play jump animation if we've been in the air longer than the threshold
		sprite.play("jump")
	elif direction:
		sprite.play("walk")
	else:
		sprite.play("idle")

	move_and_slide() # Essential CharacterBody2D function
	# Check for collisions that happened during move_and_slide
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			# Check if the collided object is in the 'pushable' group
			if collider and collider.is_in_group("pushable"):
				# Check if the collider is a RigidBody2D (optional but good practice)
				if collider is RigidBody2D:
					# Calculate push direction (based on collision normal, points away from the wall/boulder)
					var push_direction = collision.get_normal().slide(Vector2.UP).normalized()
					# If the normal is mostly horizontal, apply horizontal force
					if abs(collision.get_normal().x) > 0.5:
						# Apply force away from the player, scaled by PUSH_FORCE
						# We use -collision.get_normal() which points away from the surface hit
						# Multiply by a constant force value
						collider.apply_central_force(-collision.get_normal() * PUSH_FORCE)

# Check if player has fallen below the death threshold
func check_fall_death() -> void:
	if global_position.y > DEATH_Y_THRESHOLD:
		die(GameManager.DeathCause.FALL)

# Handle player death with optional cause parameter
func die(cause: GameManager.DeathCause = GameManager.DeathCause.CUSTOM) -> void:
	# Disable input and physics processing
	set_physics_process(false)
	set_process_input(false)
	
	# Use the GameManager to handle the death
	GameManager.kill_player(cause)
