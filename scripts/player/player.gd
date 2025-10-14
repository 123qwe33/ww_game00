extends Character

# Add to "player" group so squirrels can detect us
func _ready():
	add_to_group("player")
