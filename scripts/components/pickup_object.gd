extends Node2D

# If true, the object will be removed after being picked up
@export var remove_on_pickup: bool = true
# Optional item ID or type to identify what was picked up
@export var item_id: String = "generic_item"
# Delay before the dropper can pick up this item again
@export var dropper_cooldown: float = 0.75  # Three-quarter second delay

# Reference to the entity that dropped this item (if any)
var dropped_by = null

func _ready():
	# Make sure the Area2D child has a body_entered signal connected
	$Area2D.body_entered.connect(_on_Area2D_body_entered)
	
	# If this item was dropped by someone, start a timer to clear the reference
	if dropped_by:
		var timer = get_tree().create_timer(dropper_cooldown)
		timer.timeout.connect(func(): dropped_by = null)

func _on_Area2D_body_entered(body):
	# Skip if this is the entity that dropped the item and cooldown hasn't expired
	if body == dropped_by:
		return
		
	# Check if the colliding body can collect items (has the method)
	if body.has_method("collect_item"):
		# Call the collect_item method on the body
		body.collect_item(item_id)
		
		SoundManager.play_fx_sound(item_id)
		
		# Remove the object if configured to do so
		if remove_on_pickup:
			queue_free()
