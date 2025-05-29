extends Node2D

@onready var Canvas = $CanvasLayer
@onready var PromptLabel = Canvas.find_child("Label", true, true)

func _ready():
	Canvas.hide()

func hide_prompt():
	Canvas.hide()

func display_prompt(title, timeout = null):
	print("Displaying prompt: ", title)
	PromptLabel.text = title
	Canvas.show()
	if timeout:
		print("Prompt will hide after timeout: ", timeout)
		await get_tree().create_timer(timeout).timeout
		Canvas.hide()
