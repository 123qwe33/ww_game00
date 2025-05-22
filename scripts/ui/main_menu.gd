extends Control

# Node references
@onready var new_game_sound = $NewGameSound

func _on_start_button_pressed() -> void:
	# First play the sound effect
	new_game_sound.playing = true  # Play the sound
	
	# Wait for the sound to finish before changing scenes
	await get_tree().create_timer(1.0).timeout  # Adjust timing as needed for your sound
	
	# Change the current scene to the first level
	var error = get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")
	if error != OK:
		print("Error changing scene: ", error)

func _on_quit_to_desktop_button_pressed():
	get_tree().quit()
