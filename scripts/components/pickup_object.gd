extends Node2D

# If true, the object will be removed after being picked up
@export var remove_on_pickup: bool = true
# Optional item ID or type to identify what was picked up
@export var item_id: String = "generic_item"
# Optional pickup sound
@export var pickup_sound: AudioStream

func _ready():
	# Make sure the Area2D child has a body_entered signal connected
	$Area2D.body_entered.connect(_on_Area2D_body_entered)

func _on_Area2D_body_entered(body):
	# Check if the colliding body can collect items (has the method)
	if body.has_method("collect_item"):
		# Call the collect_item method on the body
		body.collect_item(item_id)
		
		# Play pickup sound if available
		if pickup_sound != null and has_node("AudioStreamPlayer"):
			$AudioStreamPlayer.stream = pickup_sound
			$AudioStreamPlayer.play()
		
		# Remove the object if configured to do so
		if remove_on_pickup:
			queue_free()
