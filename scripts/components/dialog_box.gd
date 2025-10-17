extends Control

@onready var label = $PanelContainer/MarginContainer/Label
@onready var panel = $PanelContainer
@onready var animation_player = $AnimationPlayer

var is_open: bool = false

