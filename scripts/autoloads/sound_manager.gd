extends Node

var hover_sounds = [
	preload("res://assets/audio/sfx/ui/bing.wav")
]

@onready var menu_player = AudioStreamPlayer.new()
@onready var fx_player = AudioStreamPlayer.new()
@onready var music_player = AudioStreamPlayer.new()  # AudioStreamPlayer for MIDI
@onready var midi_player = MidiPlayer.new()  # MidiPlayer instance
# Lists of music tracks and associated scene names
var music_tracks = {
	"quiet_forest": "res://assets/audio/music/Quiet_Forest.mid",
	"ww_theme": "res://assets/audio/music/georgia01.mid",
	"menu": "res://assets/audio/music/menu.mid",
	"phantom": "res://assets/audio/music/The-Phantom-Of-The-Opera.mid",
}
var fx_sounds = {
	"land": preload("res://assets/audio/sfx/movement/jump_land_grass.mp3"),
	"fall": preload("res://assets/audio/sfx/events/fall.wav"),
	"acorn": preload("res://assets/audio/sfx/objects/bite-small2.wav"),
}
var soundfonts = {
	"flute": "res://assets/audio/fonts/Flute (Beach's Backyard).sf2"
}

func _ready():
	add_child(music_player)  # Add the AudioStreamPlayer as a child
	add_child(fx_player)  # Add the AudioStreamPlayer as a child
	music_player.add_child(midi_player)  # Add MidiPlayer as a child of AudioStreamPlayer
	add_child(menu_player) # Add the menu effect player to the scene

func play_music(track, font = "flute", speed = 1.0):
	midi_player.stop()  # Stop any currently playing MIDI
	midi_player.file = music_tracks[track]
	midi_player.soundfont = soundfonts[font]
	midi_player.loop = true
	midi_player.play_speed = speed  # Set the playback speed
	midi_player.play()

func play_fx_sound(name):
	if (fx_player):
		fx_player.stream = fx_sounds[name]
		fx_player.play()

func play_hover_sound():
	if (menu_player):
		menu_player.stream = hover_sounds[0]
		menu_player.play()
