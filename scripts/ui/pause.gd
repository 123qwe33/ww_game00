extends Control

@onready var canvas_layer = $CanvasLayer
@onready var button_container = get_node("/root/PauseMenu/CanvasLayer/MarginContainer/CenterContainer/VBoxContainer/ButtonContainer")

var selected_index = 0 # This will track the currently selected button
var buttons = [] # This will hold references to buttons for easy access

# Path to your main menu scene
const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"

func _ready():
	# Hide the menu initially (should also be set in the scene file)
	canvas_layer.hide()
	# Ensure this node processes input even when the scene tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Add buttons to the list for navigation
	for child in button_container.get_children():
		if child is Button:
			buttons.append(child)

	if buttons.size() > 0:
		buttons[0].grab_focus()

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
	
	# Set the initial button selection
	selected_index = 0
	update_button_selection()

func _on_resume_button_pressed():
	# Simply unpause and hide the menu
	toggle_pause()

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

func _on_button_focus():
		SoundManager.play_hover_sound()  # Play hover sound when button is focused

func _input(event):
	if not get_tree().paused:
		return # Ignore input if the game is not paused

	# Get the currently focused button
	var focused = get_viewport().gui_get_focus_owner()
	if focused == null:
		return

	if event.is_action_pressed("ui_down"):
		var neighbor_path = focused.focus_neighbor_bottom
		var neighbor = focused.get_node_or_null(neighbor_path)
		if neighbor:
				neighbor.grab_focus()
	elif event.is_action_pressed("ui_up"):
		var neighbor_path = focused.focus_neighbor_top
		var neighbor = focused.get_node_or_null(neighbor_path)
		if neighbor:
				neighbor.grab_focus()
	elif event.is_action_pressed("ui_accept"):
		focused.emit_signal("pressed")


func update_button_selection():
	for i in range(buttons.size()):
		# Update to button's focus state to indicate selection
		if i == selected_index:
			buttons[i].grab_focus()
