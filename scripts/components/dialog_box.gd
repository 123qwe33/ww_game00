extends Control

# Signal emitted when dialog is closed, passes the character who owned the dialog
signal dialog_closed(character: Node2D)

# Preload InteractionArea scene
const InteractionArea = preload("res://scenes/components/interaction_area.tscn")

# Node references - will be fetched in _ready
var label: Label = null
var panel: PanelContainer = null
var animation_player: AnimationPlayer = null
var indicator_label: Label = null
var interaction_area: Area2D = null

const FADE_DURATION = 0.2
const OFFSET_ABOVE_CHARACTER = Vector2(0, -150)

var is_open: bool = false
var target_character: Node2D = null
var gives_item: bool = false  # If true, character drops held item when dialog closes

# Multi-slide dialog support
var dialog_slides: Array = []
var current_slide_index: int = 0

func _ready():
	# Fetch child nodes explicitly
	panel = get_node("PanelContainer") as PanelContainer
	label = get_node("PanelContainer/MarginContainer/Label") as Label
	indicator_label = get_node("PanelContainer/MarginContainer2/IndicatorLabel") as Label
	animation_player = get_node("AnimationPlayer") as AnimationPlayer

	# Verify nodes were found
	if not label or not panel or not animation_player or not indicator_label:
		push_error("DialogBox: Failed to find required child nodes!")
		push_error("  - Panel: %s" % panel)
		push_error("  - Label: %s" % label)
		push_error("  - IndicatorLabel: %s" % indicator_label)
		push_error("  - AnimationPlayer: %s" % animation_player)
		return

	# Create and add InteractionArea
	interaction_area = InteractionArea.instantiate()
	add_child(interaction_area)
	interaction_area.interact_pressed.connect(_on_interact_pressed)

	# Start hidden
	modulate.a = 0.0
	visible = false
	indicator_label.visible = false

func _on_interact_pressed(_player: Character):
	"""Called when a player in range presses their interact action"""
	advance()

func show_dialog(text: String, character: Node2D = null, drop_item: bool = false):
	"""Display dialog box with given text above character (single dialog, no interaction)"""
	# Double-check nodes are available
	if not label or not panel:
		push_error("DialogBox: Cannot show dialog, nodes not initialized!")
		return

	if is_open:
		# If already open, just update text
		label.text = text
		return

	# Clear multi-slide state for simple dialog
	dialog_slides.clear()
	current_slide_index = 0

	is_open = true
	target_character = character
	gives_item = drop_item
	label.text = text

	# Hide indicator for simple dialogs
	indicator_label.visible = false

	# Resize panel to fit text
	_resize_to_fit_text()

	# Position above character if provided
	if target_character:
		_update_position()
		# Position interaction area at character location
		if interaction_area:
			interaction_area.global_position = target_character.global_position

	# Fade in
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func hide_dialog():
	"""Hide the dialog box"""
	if not is_open:
		return

	is_open = false

	# Clear multi-slide state
	dialog_slides.clear()
	current_slide_index = 0

	# Emit signal before clearing target_character so listeners can react
	if target_character:
		dialog_closed.emit(target_character)

		# If gives_item is true, make the character drop their held item
		if gives_item and target_character.has_method("drop_item"):
			# Check if character has a held item using property existence check
			if "current_held_item" in target_character and not target_character.current_held_item.is_empty():
				target_character.drop_item(target_character.current_held_item)

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(func(): visible = false)

	target_character = null
	gives_item = false

func show_multiple_dialogs(slides: Array, character: Node2D = null, drop_item: bool = false):
	"""Display multi-slide dialog with interaction support"""
	if not label or not panel or not indicator_label:
		push_error("DialogBox: Cannot show dialog, nodes not initialized!")
		return

	if slides.is_empty():
		push_warning("DialogBox: Empty slides array provided")
		return

	# Store dialog slides
	dialog_slides = slides
	current_slide_index = 0

	is_open = true
	target_character = character
	gives_item = drop_item

	# Show first slide
	_show_current_slide()

func advance():
	"""Advance to next slide or close dialog"""
	if not is_open or dialog_slides.is_empty():
		return

	current_slide_index += 1

	if current_slide_index < dialog_slides.size():
		# Show next slide
		_show_current_slide()
	else:
		# No more slides, close dialog
		hide_dialog()

func _show_current_slide():
	"""Display the current slide with proper indicator"""
	if current_slide_index >= dialog_slides.size():
		return

	label.text = dialog_slides[current_slide_index]

	# Update indicator
	_update_indicator()

	# Resize panel to fit text
	_resize_to_fit_text()

	# Position above character if provided
	if target_character:
		_update_position()
		# Position interaction area at character location
		if interaction_area:
			interaction_area.global_position = target_character.global_position

	# Fade in if first slide
	if current_slide_index == 0:
		visible = true
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func _update_indicator():
	"""Update indicator based on remaining slides"""
	if not indicator_label:
		return

	if dialog_slides.is_empty():
		indicator_label.visible = false
		return

	# Show indicator if there are more slides or this is the last slide
	indicator_label.visible = true

	if current_slide_index < dialog_slides.size() - 1:
		# More slides remaining
		indicator_label.text = "▼"
	else:
		# Last slide
		indicator_label.text = "✓"

func _process(_delta):
	# Keep dialog positioned above character while open
	if is_open and target_character:
		_update_position()
		# Position interaction area at character location (world space)
		if interaction_area:
			interaction_area.global_position = target_character.global_position

func _update_position():
	"""Position dialog box above the target character"""
	if target_character:
		global_position = target_character.global_position + OFFSET_ABOVE_CHARACTER
		# Center the panel horizontally
		panel.position.x = -panel.size.x / 2.0

func _resize_to_fit_text():
	"""Adjust panel size to fit text content"""
	# Let the label calculate its size based on text
	label.size = Vector2.ZERO
	await get_tree().process_frame

	# Panel will auto-resize based on label content
	panel.size = Vector2.ZERO
