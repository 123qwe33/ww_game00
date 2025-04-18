extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D # Ensure this matches your node name
@onready var direction_timer = $DirectionTimer

# States Enum
enum State { IDLE, WALKING }

const SPEED = 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_state = State.IDLE
var direction = 1 # 1 for right, -1 for left

# Define duration ranges for states (adjust as needed)
const IDLE_DURATION_MIN = 2.0
const IDLE_DURATION_MAX = 5.0
const WALK_DURATION_MIN = 3.0
const WALK_DURATION_MAX = 6.0

func _ready():
	# Start in IDLE state
	set_state(State.IDLE)

func set_state(new_state):
	current_state = new_state
	match current_state:
		State.IDLE:
			# Play idle animation (or stop if none exists)
			if sprite.sprite_frames.has_animation("idle"):
				sprite.play("idle")
			else:
				sprite.stop()
				sprite.frame = 0
			# Set timer for idle duration
			direction_timer.wait_time = randf_range(IDLE_DURATION_MIN, IDLE_DURATION_MAX)
			direction_timer.start()

		State.WALKING:
			# Pick a random direction to start walking
			direction = [-1, 1].pick_random()
			# Play walk animation
			sprite.play("walk")
			# Set timer for walking duration
			direction_timer.wait_time = randf_range(WALK_DURATION_MIN, WALK_DURATION_MAX)
			direction_timer.start()

func _physics_process(delta):
	# --- Apply Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Reset vertical velocity slightly when on floor to prevent bouncing issues
		# velocity.y = max(velocity.y, 0) # Or adjust as needed
		pass # Usually move_and_slide handles this well enough

	# --- Handle State Logic ---
	match current_state:
		State.IDLE:
			# Slow down horizontally when idle
			velocity.x = move_toward(velocity.x, 0, SPEED / 2) # Gradual stop

		State.WALKING:
			# Set horizontal velocity
			velocity.x = direction * SPEED

			# Flip sprite based on direction
			if direction > 0: # Moving Right
				sprite.flip_h = true
			elif direction < 0: # Moving Left
				sprite.flip_h = false

			# Check for wall collision only when walking
			if is_on_wall() and is_on_floor():
				direction *= -1 # Reverse direction immediately
				# Don't reset the timer here, let it finish its walk duration

	# --- Move ---
	move_and_slide()


func _on_direction_timer_timeout():
	# Timer finished, transition to the other state
	if current_state == State.IDLE:
		set_state(State.WALKING)
	elif current_state == State.WALKING:
		set_state(State.IDLE)
