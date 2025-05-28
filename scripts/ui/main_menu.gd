extends Control

# Node references
@onready var new_game_sound = $NewGameSound
@onready var button_container = get_node("/root/MainMenu/MarginContainer/CenterContainer/VBoxContainer")

var selected_index = 0 # This will track the currently selected button
var buttons = [] # This will hold references to buttons for easy access

func _ready():
	SoundManager.play_music('menu', 'flute')
	# Add buttons to the list for navigation
	for child in button_container.get_children():
		if child is Button:
			buttons.append(child)
	
	# Set the initial button selection
	update_button_selection()

func _on_start_button_pressed() -> void:
		# First play the sound effect
		new_game_sound.playing = true  # Play the sound
		
		# Wait for the sound to finish before changing scenes
		await get_tree().create_timer(1.0).timeout  # Adjust timing as needed for your sound

		GameManager.start_game()  # Start the game

func _on_quit_to_desktop_button_pressed():
		get_tree().quit()

func _on_button_mouse_entered():
		SoundManager.play_hover_sound()

func _on_button_focus():
		SoundManager.play_hover_sound()  # Play hover sound when button is focused

func _input(event):
	if event.is_action_pressed("ui_down"):
		selected_index = (selected_index + 1) % buttons.size() # Move down in the button list
		update_button_selection()
	elif event.is_action_pressed("ui_up"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size() # Move up in the button list
		update_button_selection()
	elif event.is_action_pressed("ui_accept"): # Usually Enter or Space
		buttons[selected_index].emit_signal("pressed") # Trigger the pressed signal of the selected button

func update_button_selection():
	for i in range(buttons.size()):
		# Update to button's focus state to indicate selection
		if i == selected_index:
			buttons[i].grab_focus()
