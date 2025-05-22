extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var direction_timer = $DirectionTimer
@onready var ledge_detector = $RayCast2D
@onready var held_item_sprite = $HeldItem/Sprite2D

# States Enum
enum State { IDLE, WALKING, FLEEING }

const SPEED = 100.0
const FLEE_SPEED = 180.0  # Faster when scared
const FLEE_DISTANCE = 300.0  # Distance at which squirrel notices player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_state = State.IDLE
var direction = 1 # 1 for right, -1 for left
var player = null  # Reference to player
var can_change_direction = true
var direction_change_cooldown = 0.5 # seconds
var inventory: Dictionary = {}  # Tracks items collected by the squirrel
var current_held_item: String = ""  # ID of the currently held item
const MAX_INVENTORY_SIZE = 1  # Squirrels can only hold 1 item at a time
const MAX_STACK_SIZE = 1  # Squirrels don't stack items

# Define duration ranges for states (adjust as needed)
const IDLE_DURATION_MIN = 2.0
const IDLE_DURATION_MAX = 5.0
const WALK_DURATION_MIN = 3.0
const WALK_DURATION_MAX = 6.0

func _ready():
	# Add to "squirrel" group for detection by pickup objects
	add_to_group("squirrel")
	
	# Initialize the held item sprite to be invisible at start
	held_item_sprite.visible = false
	
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
		# Position held item to the right of squirrel
		$HeldItem.position.x = abs($HeldItem.position.x)
		# Flip held item sprite to match squirrel direction
		held_item_sprite.flip_h = false
	elif direction < 0: # Moving Left
		sprite.flip_h = false
		# Position raycast to left side
		ledge_detector.position.x = -abs(ledge_detector.position.x)
		ledge_detector.target_position = Vector2(0, 40)
		# Position held item to the left of squirrel
		$HeldItem.position.x = -abs($HeldItem.position.x)
		# Make sure held item sprite is not flipped when facing left
		held_item_sprite.flip_h = true
		
func change_direction_with_cooldown():
	direction *= -1 # Reverse direction
	can_change_direction = false
	# Create a timer to reset the cooldown
	get_tree().create_timer(direction_change_cooldown).timeout.connect(func(): can_change_direction = true)

func check_wall_collision():
	var collision = get_last_slide_collision()
	if collision:
		# Check if the collision normal is mostly horizontal (a wall)
		# Use a threshold like 0.7 to avoid triggering on slight slopes mistaken for walls
		if abs(collision.get_normal().x) > 0.7 and can_change_direction:
			change_direction_with_cooldown()
			# Don't reset the timer here, let it finish its walk duration

func check_ledge_detection():
	if is_on_floor() and ledge_detector.is_colliding() == false and can_change_direction:
		# No floor detected ahead, turn around
		change_direction_with_cooldown()

func _on_direction_timer_timeout():
	# Timer finished, transition to the other state
	# Only change states if not currently fleeing
	if current_state == State.IDLE:
		set_state(State.WALKING)
	elif current_state == State.WALKING:
		set_state(State.IDLE)
	# Note: We ignore timer while in FLEEING state

func collect_item(item_id: String) -> void:
	# Squirrels are simpler - they just drop whatever they're holding if they pick up something new
	if inventory.size() >= MAX_INVENTORY_SIZE:
		# Drop the currently held item first
		var old_item = current_held_item
		if old_item != "":
			drop_item(old_item)
	
	# Now add the new item to inventory
	if inventory.has(item_id):
		# If exists, increment quantity
		inventory[item_id] += 1
	else:
		# If new, add to inventory with quantity 1
		inventory[item_id] = 1
	
	# Update the currently held item
	current_held_item = item_id
	update_held_item_display()
	
	print("Squirrel picked up " + item_id + " (Total: " + str(inventory[item_id]) + ")")

func drop_item(item_id: String) -> void:
	if not inventory.has(item_id) or inventory[item_id] <= 0:
		return  # Can't drop an item we don't have
	
	# Reduce the quantity in inventory
	inventory[item_id] -= 1
	
	# If quantity is zero, remove the item from inventory
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
		# If we dropped the currently held item, clear it
		if current_held_item == item_id:
			current_held_item = ""
			update_held_item_display()
	
	# Spawn the dropped item in the world
	spawn_dropped_item(item_id)
	
	print("Squirrel dropped " + item_id)

func spawn_dropped_item(item_id: String) -> void:
	# Get the path to the scene based on item_id
	var scene_path = ""
	match item_id:
		"nut":
			scene_path = "res://scenes/components/nut.tscn"
		"shears":
			scene_path = "res://scenes/components/shears.tscn"
		# Add more items here as needed
		_:
			print("No scene defined for item: " + item_id)
			return
	
	# Load and instantiate the scene
	var item_scene = load(scene_path)
	if item_scene:
		var item_instance = item_scene.instantiate()
		# Set this squirrel as the dropper to prevent immediate re-pickup
		item_instance.dropped_by = self
		# Add the item to the scene
		get_tree().current_scene.add_child(item_instance)
		# Position it slightly in front of the squirrel, near the ground
		var horizontal_offset = 30.0  # Distance in front of squirrel (smaller than player)
		var vertical_offset = 20.0  # Lower position, near feet level (smaller than player)
		var direction_factor = 1 if sprite.flip_h else -1  # Check which way squirrel is facing (flipped from player due to different sprite orientation)
		item_instance.global_position = global_position + Vector2(direction_factor * horizontal_offset, vertical_offset)
	else:
		print("Failed to load scene: " + scene_path)
	
func update_held_item_display() -> void:
	# Hide the held item sprite by default
	held_item_sprite.visible = false
	
	if current_held_item.is_empty():
		return
		
	# For now, hardcode item textures based on ID
	# In a more complete implementation, this would use a resource system
	match current_held_item:
		"nut":
			held_item_sprite.texture = load("res://assets/sprites/statics/nut.png")
			held_item_sprite.visible = true
			held_item_sprite.scale = Vector2(1.5, 1.5)  # Smaller than player's held item
		"shears":
			held_item_sprite.texture = load("res://assets/sprites/statics/shears.png")
			held_item_sprite.visible = true
			held_item_sprite.scale = Vector2(1.5, 1.5)  # Smaller than player's held item
		# Add more items here as needed
		_:
			# Generic or unknown item, don't show anything
			pass
