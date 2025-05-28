extends Node

var hover_sounds = [
	preload("res://assets/audio/sfx/ui/bing.wav")
]

@onready var menu_player = AudioStreamPlayer.new()
@onready var music_player = AudioStreamPlayer.new()  # AudioStreamPlayer for MIDI
@onready var midi_player = MidiPlayer.new()  # MidiPlayer instance

func _ready():
	add_child(music_player)  # Add the AudioStreamPlayer as a child
	music_player.add_child(midi_player)  # Add MidiPlayer as a child of AudioStreamPlayer

	# Load MIDI file and soundfont
	midi_player.file = "res://assets/audio/music/Quiet_Forest.mid"  # Set your MIDI file path
	midi_player.soundfont = "res://assets/audio/fonts/Flute (Beach's Backyard).sf2"  # Set your SoundFont path
	midi_player.loop = true  # Set to loop
	midi_player.play()  # Start playback
	add_child(menu_player)

func play_hover_sound():
	if (menu_player):
		menu_player.stream = hover_sounds[0]
		menu_player.play()
