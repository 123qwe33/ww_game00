extends Control

# Node references - will be fetched in _ready
var label: Label = null
var panel: PanelContainer = null
var animation_player: AnimationPlayer = null

const FADE_DURATION = 0.2
const OFFSET_ABOVE_CHARACTER = Vector2(0, -60)

var is_open: bool = false
var target_character: Node2D = null

func _ready():
	# Fetch child nodes explicitly
	panel = get_node("PanelContainer") as PanelContainer
	label = get_node("PanelContainer/MarginContainer/Label") as Label
	animation_player = get_node("AnimationPlayer") as AnimationPlayer

	# Verify nodes were found
	if not label or not panel or not animation_player:
		push_error("DialogBox: Failed to find required child nodes!")
		push_error("  - Panel: %s" % panel)
		push_error("  - Label: %s" % label)
		push_error("  - AnimationPlayer: %s" % animation_player)
		return

	# Start hidden
	modulate.a = 0.0
	visible = false

func show_dialog(text: String, character: Node2D = null):
	"""Display dialog box with given text above character"""
	# Double-check nodes are available
	if not label or not panel:
		push_error("DialogBox: Cannot show dialog, nodes not initialized!")
		return

	if is_open:
		# If already open, just update text
		label.text = text
		return

	is_open = true
	target_character = character
	label.text = text

	# Resize panel to fit text
	_resize_to_fit_text()

	# Position above character if provided
	if target_character:
		_update_position()

	# Fade in
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func hide_dialog():
	"""Hide the dialog box"""
	if not is_open:
		return

	is_open = false

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(func(): visible = false)

	target_character = null

func _process(_delta):
	# Keep dialog positioned above character while open
	if is_open and target_character:
		_update_position()

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
