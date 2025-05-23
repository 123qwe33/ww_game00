extends Control

@onready var canvas_layer = $CanvasLayer # Add this line

# Path to your main menu scene
const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"

func _ready():
	# Hide the menu initially (should also be set in the scene file)
	canvas_layer.hide()
	# Ensure this node processes input even when the scene tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called automatically by the engine for input not handled elsewhere
func _unhandled_input(event):
	# Get the currently active scene's root node
	var current_scene = get_tree().current_scene
	# Check if the current scene is the main menu
	if current_scene and current_scene.name == "MainMenu":
		# If the current scene is the main menu, ignore input events
		return
	# Check if the 'pause' action was just pressed
	if event.is_action_pressed("pause"):
		# Toggle pause state and menu visibility
		toggle_pause()
		# Mark the event as handled so other nodes don't process it
		get_viewport().set_input_as_handled()

func toggle_pause():
	# Check current pause state
	var is_paused = get_tree().paused
	# Set the opposite state
	get_tree().paused = not is_paused
	# Show/hide the pause menu accordingly
	canvas_layer.visible = not is_paused

func _on_resume_button_pressed():
	# Simply unpause and hide the menu
	toggle_pause()

func _on_options_button_pressed():
	print("Options button pressed (implement options menu loading here)")
	# You might load/show another UI scene for options
	pass

func _on_quit_to_menu_button_pressed():
	# IMPORTANT: Unpause before changing scenes, otherwise the new scene might stay paused!
	get_tree().paused = false
	# Change to the main menu scene
	var error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	canvas_layer.hide()
	if error != OK:
		print("Error loading main menu: ", error)

func _on_quit_to_desktop_button_pressed():
	# IMPORTANT: Unpause first (optional but good practice)
	get_tree().paused = false
	get_tree().quit()

func _on_button_mouse_entered():
		SoundManager.play_hover_sound()
