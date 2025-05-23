extends Node

var hover_sounds = [
    preload("res://assets/audio/sfx/ui/bing.wav")
]

@onready var audio_player = AudioStreamPlayer.new()

func _ready():
    add_child(audio_player)

func play_hover_sound():
    audio_player.stream = hover_sounds[0]
    audio_player.play()
