extends Node

var hover_sounds = [
	preload("res://assets/audio/sfx/ui/bing.wav")
]

@onready var menu_player = AudioStreamPlayer.new()
@onready var music_player = AudioStreamPlayer.new()  # AudioStreamPlayer for MIDI
@onready var midi_player = MidiPlayer.new()  # MidiPlayer instance
# Lists of music tracks and associated scene names
var music_tracks = {
	"quiet_forest": "res://assets/audio/music/Quiet_Forest.mid"
}
var soundfonts = {
	"flute": "res://assets/audio/fonts/Flute (Beach's Backyard).sf2"
}

func _ready():
	add_child(music_player)  # Add the AudioStreamPlayer as a child
	music_player.add_child(midi_player)  # Add MidiPlayer as a child of AudioStreamPlayer
	add_child(menu_player) # Add the menu effect player to the scene

	# Load MIDI file and soundfont
	play_music(music_tracks["quiet_forest"], soundfonts["flute"])

func play_music(track, font):
	midi_player.file = track
	midi_player.soundfont = font
	midi_player.loop = true
	midi_player.play()

func play_hover_sound():
	if (menu_player):
		menu_player.stream = hover_sounds[0]
		menu_player.play()
