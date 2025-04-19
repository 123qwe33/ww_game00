extends Control


func _on_start_button_pressed() -> void:
		# Change the current scene to the first level
		var error = get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")
		if error != OK:
				print("Error changing scene: ", error)
