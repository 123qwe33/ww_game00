extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const AIR_THRESHOLD = 0.15  # Time in seconds to ignore brief air states

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var air_time = 0.0  # Tracks how long player has been in the air

func _physics_process(delta):
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
