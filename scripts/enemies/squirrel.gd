extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var direction_timer = $DirectionTimer
@onready var ledge_detector = $RayCast2D

# States Enum
enum State { IDLE, WALKING, FLEEING }

const SPEED = 100.0
const FLEE_SPEED = 180.0  # Faster when scared
const FLEE_DISTANCE = 300.0  # Distance at which squirrel notices player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_state = State.IDLE
var direction = 1 # 1 for right, -1 for left
var player = null  # Reference to player

# Define duration ranges for states (adjust as needed)
const IDLE_DURATION_MIN = 2.0
const IDLE_DURATION_MAX = 5.0
const WALK_DURATION_MIN = 3.0
const WALK_DURATION_MAX = 6.0

func _ready():
	# Start in IDLE state
	set_state(State.IDLE)

	# Configure ledge detector
	ledge_detector.enabled = true
	ledge_detector.target_position = Vector2(0, 40)

	# Find player in the scene
	await get_tree().process_frame  # Wait one frame to ensure scene is fully loaded
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Warning: Player not found! Make sure player is in group 'player'")

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
			
		State.FLEEING:
			# Play walk animation but faster (or run animation if available)
			if sprite.sprite_frames.has_animation("run"):
				sprite.play("run")
			else:
				sprite.play("walk")
				# Speed up animation for fleeing
				sprite.speed_scale = 1.5
			
			# No timer reset - we'll stay in this state until player moves away

func _physics_process(delta):
	# --- Check for player proximity and update state if needed ---
	check_player_proximity()
	
	# --- Apply Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Reset vertical velocity when on floor
		velocity.y = 0 # Or a small positive value if needed

	# --- Handle State Logic ---
	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, SPEED / 2) # Gradual stop

		State.WALKING:
			# Set horizontal velocity
			velocity.x = direction * SPEED

			# Flip sprite based on direction
			update_sprite_direction()

		State.FLEEING:
			# Set flee direction away from player
			if player:
				# Calculate direction away from player
				var flee_direction = global_position - player.global_position
				direction = 1 if flee_direction.x > 0 else -1
				
				# Move faster when fleeing
				velocity.x = direction * FLEE_SPEED
				
				# Flip sprite based on direction
				update_sprite_direction()

	# --- Move (Common to all states) ---
	move_and_slide() # Apply the calculated velocity

	# --- Post-Move Checks (for WALKING and FLEEING states after moving) ---
	if (current_state == State.WALKING or current_state == State.FLEEING) and is_on_floor():
		check_wall_collision()
		check_ledge_detection()

func check_player_proximity():
	# Skip if no player reference
	if not player:
		return
		
	# Calculate distance to player
	var distance = global_position.distance_to(player.global_position)
	
	# Check if we need to flee
	if distance < FLEE_DISTANCE and current_state != State.FLEEING:
		set_state(State.FLEEING)
	# Check if we can return to normal states
	elif distance >= FLEE_DISTANCE * 1.5 and current_state == State.FLEEING:
		# Return to idle state when player is far enough away
		set_state(State.IDLE)
		# Reset animation speed if it was modified
		sprite.speed_scale = 1.0

func update_sprite_direction():
	# Flip sprite based on direction
	if direction > 0: # Moving Right
		sprite.flip_h = true
		# Position raycast to right side
		ledge_detector.position.x = abs(ledge_detector.position.x)
		ledge_detector.target_position = Vector2(0, 40)
	elif direction < 0: # Moving Left
		sprite.flip_h = false
		# Position raycast to left side
		ledge_detector.position.x = -abs(ledge_detector.position.x)
		ledge_detector.target_position = Vector2(0, 40)
		
func check_wall_collision():
	var collision = get_last_slide_collision()
	if collision:
		# Check if the collision normal is mostly horizontal (a wall)
		# Use a threshold like 0.7 to avoid triggering on slight slopes mistaken for walls
		if abs(collision.get_normal().x) > 0.7:
			direction *= -1 # Reverse direction
			# Don't reset the timer here, let it finish its walk duration

func check_ledge_detection():
	if is_on_floor() and ledge_detector.is_colliding() == false:
		# No floor detected ahead, turn around
		direction *= -1 # Reverse direction

func _on_direction_timer_timeout():
	# Timer finished, transition to the other state
	# Only change states if not currently fleeing
	if current_state == State.IDLE:
		set_state(State.WALKING)
	elif current_state == State.WALKING:
		set_state(State.IDLE)
	# Note: We ignore timer while in FLEEING state
