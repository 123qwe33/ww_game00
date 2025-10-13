extends Node

# Main menu scene path
const MAIN_MENU_SCENE = "res://scenes/ui/main_menu.tscn"

# Level-to-music track mapping
var level_music = {
	1: "quiet_forest",
	2: "phantom"
}

# Default music settings
const DEFAULT_SOUNDFONT = "flute"
const DEFAULT_SPEED = 0.88

@onready var TitleCard = get_node_or_null("/root/TitleCard")
@onready var Prompt = get_node_or_null("/root/Prompt")

# Signal for when player dies - carry death cause for potential future use
signal player_died(cause)

func play_level_music(level_number: int):
	# Play music for the specified level
	if level_music.has(level_number):
		var track = level_music[level_number]
		SoundManager.play_music(track, DEFAULT_SOUNDFONT, DEFAULT_SPEED)
	else:
		# Fallback to quiet_forest if level has no defined music
		print("No music defined for level ", level_number, ", using fallback")
		SoundManager.play_music("quiet_forest", DEFAULT_SOUNDFONT, DEFAULT_SPEED)

func end_game():
	TitleCard.display("To Be Continued...", 999)

func start_game():
	# Change the current scene to the first level
	var error = get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")
	if error != OK:
		print("Error changing scene: ", error)
	play_level_music(1)
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

func next_level():
	# Get current level number from scene name
	var current_scene = get_tree().current_scene
	var scene_name = current_scene.name # e.g., "level_01"
	# Extract level number
	var level_number = int(scene_name.get_slice("_", 1)) # Get the number after the underscore
	var next_level_number = level_number + 1
	var next_scene_path = "res://scenes/levels/level_%02d.tscn" % next_level_number
	var error = get_tree().change_scene_to_file(next_scene_path)
	if error == OK:
		play_level_music(next_level_number)
