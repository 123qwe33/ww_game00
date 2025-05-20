extends Node2D

# Signal emitted when the vine is cut
signal cut

# Whether this item has been cut already
var is_cut: bool = false

# Sound to play when cut (optional)
@export var cut_sound: AudioStream

# The particle effect to spawn when cut (optional)
@export var cut_particles_scene: PackedScene

# Function for handling collision with player
func _on_body_entered(body):
	# Skip if already cut
	if is_cut:
		return
		
	# Check if it's the player
	if body.is_in_group("player"):
		# Check if player is holding shears
		if body.current_held_item == "shears":
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
		$AudioStreamPlayer.stream = cut_sound
		$AudioStreamPlayer.play()
	
	# Spawn particles if available
	if cut_particles_scene != null:
		var particles = cut_particles_scene.instantiate()
		get_parent().add_child(particles)
		particles.global_position = global_position
		
	# Make the vine disappear
	queue_free()

func _ready():
	# Connect the body entered signal
	# We'll need to add an Area2D node to detect collisions
	if has_node("CutArea"):
		$CutArea.body_entered.connect(_on_body_entered)
