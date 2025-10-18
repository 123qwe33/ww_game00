extends Node2D

# Signal emitted when the vine is cut
signal cut

const InteractionArea = preload("res://scenes/components/interaction_area.tscn")

# Whether this item has been cut already
var is_cut: bool = false

# Sound to play when cut (optional)
@export var cut_sound: AudioStream

# The particle effect to spawn when cut (optional)
@export var cut_particles_scene: PackedScene

# Reference to the interaction area
var interaction_area: Area2D = null

# Function for handling player interaction
func _on_interact_pressed(player: Character):
	# Player has the required item (shears) and pressed interact
	cut_self()

# Cut the vine
func cut_self():
	# Skip if already cut
	if is_cut:
		return
		
	is_cut = true
	
	# Emit the cut signal
	emit_signal("cut")
	
	# Play cut sound if available
	if cut_sound != null and has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.play()
	
	# Spawn particles if available
	if cut_particles_scene != null:
		var particles = cut_particles_scene.instantiate()
		get_parent().add_child(particles)
		particles.global_position = global_position
		await get_tree().create_timer(1.0).timeout
		particles.queue_free()  # Clean up particles after a short delay
		
	# Make the vine disappear after waiting for sound to finish
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _ready():
	# Create and configure interaction area
	interaction_area = InteractionArea.instantiate()
	add_child(interaction_area)

	# Set required items (shears needed to cut)
	interaction_area.required_items.append("shears")

	# Connect to interact signal
	interaction_area.interact_pressed.connect(_on_interact_pressed)

	# Set the cut sound if provided
	if cut_sound != null and has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.stream = cut_sound
