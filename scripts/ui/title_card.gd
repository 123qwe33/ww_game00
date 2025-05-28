extends Control

@onready var TitleCardCanvas = TitleCard.get_child(0)
@onready var TitleCardLabel = TitleCard.find_child("Label", true, true)

func _ready():
	TitleCardCanvas.hide()

func display(title, timeout = 3.0):
	TitleCardLabel.text = title
	TitleCardCanvas.show()
	# Hide it after a short delay
	await get_tree().create_timer(timeout).timeout
	TitleCardCanvas.hide()
