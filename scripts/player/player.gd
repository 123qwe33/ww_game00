extends CharacterBody2D

# Add to "player" group so squirrels can detect us
func _ready():
	add_to_group("player")
	
	# Initialize the held item sprite to be invisible at start
	held_item_sprite.visible = false

@onready var sprite = $AnimatedSprite2D
@onready var held_item_sprite = $HeldItem/Sprite2D

# Death settings
const DEATH_Y_THRESHOLD = 2000  # How far the player can fall before dying

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const AIR_THRESHOLD = 0.15  # Time in seconds to ignore brief air states
const PUSH_FORCE = 100.0 # Adjust this value later!

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var air_time = 0.0  # Tracks how long player has been in the air
var inventory: Dictionary = {}  # Tracks items collected by the player
var current_held_item: String = ""  # ID of the currently held item
const MAX_INVENTORY_SIZE = 2  # Maximum number of different items player can carry
const MAX_STACK_SIZE = 99  # Maximum number of the same item player can carry

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
		# Position held item to the right of player
		$HeldItem.position.x = abs($HeldItem.position.x)
	elif direction < 0:
		sprite.flip_h = true  # Facing left
		# Position held item to the left of player
		$HeldItem.position.x = -abs($HeldItem.position.x)
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


func collect_item(item_id: String) -> void:
	# First check if we need to drop an item due to inventory limits
	if inventory.size() >= MAX_INVENTORY_SIZE and not inventory.has(item_id):
		# We're at capacity and trying to add a new type of item, so drop an item
		drop_item(current_held_item)
	elif inventory.has(item_id) and inventory[item_id] >= MAX_STACK_SIZE:
		# This stack is at capacity, don't add more
		print("Can't carry any more " + item_id)
		return
	
	# Now add the item to inventory
	if inventory.has(item_id):
		# If exists, increment quantity
		inventory[item_id] += 1
	else:
		# If new, add to inventory with quantity 1
		inventory[item_id] = 1
	
	# Update the currently held item
	current_held_item = item_id
	update_held_item_display()
	
	print("Player picked up " + item_id + " (Total: " + str(inventory[item_id]) + ")")

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
	
	print("Player dropped " + item_id)

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
		# Set this player as the dropper to prevent immediate re-pickup
		item_instance.dropped_by = self
		# Add the item to the scene
		get_tree().current_scene.add_child(item_instance)
		# Position it slightly in front of the player
		var offset = 50.0  # Distance in front of player
		var direction_factor = -1 if sprite.flip_h else 1  # Check which way player is facing
		item_instance.global_position = global_position + Vector2(direction_factor * offset, 0)
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
			held_item_sprite.scale = Vector2(2, 2)  # Smaller than the pickup
		"shears":
			held_item_sprite.texture = load("res://assets/sprites/statics/shears.png")
			held_item_sprite.visible = true
			held_item_sprite.scale = Vector2(2, 2)  # Smaller than the pickup
		# Add more items here as needed
		_:
			# Generic or unknown item, don't show anything
			pass

func get_player_inventory() -> Dictionary:
	"""Returns a copy of the player's current inventory"""
	return inventory.duplicate()
