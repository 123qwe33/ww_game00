extends Node

# Death causes enum for future-proofing
enum DeathCause {
	FALL,
	ENEMY,
	SPIKES,
	CUSTOM
}

# Main menu scene path
const MAIN_MENU_SCENE = "res://scenes/ui/main_menu.tscn"

# Signal for when player dies - carry death cause for potential future use
signal player_died(cause: DeathCause)

func start_game():
	# Change the current scene to the first level
	var error = get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")
	if error != OK:
		print("Error changing scene: ", error)
	SoundManager.change_track("quiet_forest")

# Handles player death with any cause
func kill_player(cause: DeathCause = DeathCause.CUSTOM) -> void:
	# Emit signal for anything that needs to react to player death
	player_died.emit(cause)
	
	# Wait a brief moment before transitioning
	await get_tree().create_timer(0.5).timeout
	
	# Return to main menu
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
