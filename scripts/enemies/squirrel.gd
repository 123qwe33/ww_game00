extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D # Ensure this matches your node name

const SPEED = 100.0 # How fast the squirrel moves (Increased from 50.0)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1 # 1 for right, -1 for left

# Optional: Timer for changing direction
@onready var direction_timer = $DirectionTimer # Uncomment if you add a Timer node

func _ready():
	# Start walking animation
	sprite.play("walk")
	# Optional: randomize starting direction
	direction = [-1, 1].pick_random()
	# Optional: Timer setup
	direction_timer.wait_time = randf_range(2.0, 5.0)
	direction_timer.start()
	pass

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Determine movement based on direction ONLY if on floor
	if is_on_floor():
		velocity.x = direction * SPEED
	else:
		# Optional: reduce horizontal speed significantly while falling
		velocity.x = move_toward(velocity.x, 0, SPEED / 4)

	# Play animation based on movement (already playing walk in _ready)
	# If you add an idle animation, you'd handle switching here based on velocity.x
	if abs(velocity.x) < 0.1 and is_on_floor():
		sprite.play("idle")
	elif is_on_floor(): # Check is_on_floor again in case it just landed
		sprite.play("walk")


	# Flip sprite based on direction (reversed for left-facing default sprite)
	if direction > 0: # Moving Right
		sprite.flip_h = true # Flip horizontally (to face right)
	elif direction < 0: # Moving Left
		sprite.flip_h = false # Don't flip (show default left-facing)

	# Move the squirrel
	move_and_slide()

	# Simpler check: If it hits a wall while on the floor, turn around
	if is_on_wall() and is_on_floor():
		direction *= -1
		# Optional: Reset timer logic here...
		# if direction_timer: direction_timer.start()


# Optional: Function called when DirectionTimer times out
func _on_direction_timer_timeout():
	direction *= -1 # Reverse direction
	# Set a new random wait time
	direction_timer.wait_time = randf_range(2.0, 5.0)
	# Optional: Make sure timer is only started once if needed, or restart here
	# direction_timer.start()
