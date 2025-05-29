extends Node

# Main menu scene path
const MAIN_MENU_SCENE = "res://scenes/ui/main_menu.tscn"

@onready var TitleCard = get_node_or_null("/root/TitleCard")
@onready var Prompt = get_node_or_null("/root/Prompt")

# Signal for when player dies - carry death cause for potential future use
signal player_died(cause)

func end_game():
	TitleCard.display("To Be Continued...", 999)

func start_game():
	# Change the current scene to the first level
	var error = get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")
	if error != OK:
		print("Error changing scene: ", error)
	SoundManager.play_music("quiet_forest", "flute", 0.88)
	TitleCard.display("Chapter 1: Journey to Moomaw")
	await get_tree().create_timer(3.5).timeout
	Prompt.display_prompt("Use direction keys to move, and press X to jump.", 10)

func play_death_sound(cause):
	# Play a sound based on the cause of death
	match cause:
		'FALL':
			SoundManager.play_fx_sound("fall")

# Handles player death with any cause
func kill_player(cause):
	play_death_sound(cause)
	# Emit signal for anything that needs to react to player death
	player_died.emit(cause)
	
	# Wait a brief moment before transitioning
	await get_tree().create_timer(2).timeout
	
	# Return to main menu
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
