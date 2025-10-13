# Autoload Systems Documentation

This directory contains autoload scripts (singletons) that are globally accessible throughout the game.

## sound_manager.gd

**Purpose**: Centralized audio playback system for music, sound effects, and UI sounds.

**Key Components**:
- `menu_player`: AudioStreamPlayer for UI sounds (hover effects, clicks)
- `fx_player`: AudioStreamPlayer for gameplay sound effects
- `music_player`: AudioStreamPlayer for MIDI music playback
- `midi_player`: MidiPlayer instance for MIDI file handling

**Data Structures**:
- `music_tracks`: Dictionary mapping track names to MIDI file paths
  - Available tracks: "quiet_forest", "ww_theme", "menu", "phantom"
- `fx_sounds`: Dictionary mapping effect names to preloaded audio files
  - Available effects: "land", "fall", "nut", "shears"
- `soundfonts`: Dictionary of available soundfont files
  - Currently: "flute" soundfont

**Public Functions**:
- `play_music(track, font="flute", speed=1.0)`: Plays a MIDI music track with specified soundfont and speed
  - Automatically loops the track
  - Stops any currently playing music before starting new track
- `play_fx_sound(name)`: Plays a sound effect by name from the fx_sounds dictionary
- `play_hover_sound()`: Plays UI hover sound effect

**Usage Example**:
```gdscript
SoundManager.play_music("quiet_forest", "flute", 0.88)
SoundManager.play_fx_sound("land")
```

---

## game_manager.gd

**Purpose**: Manages game flow, level transitions, player lifecycle, and level-specific music playback.

**Key Components**:
- Level progression system
- Music-to-level association
- Player death handling
- Scene management

**Constants**:
- `MAIN_MENU_SCENE`: Path to main menu scene
- `DEFAULT_SOUNDFONT`: Default soundfont for music playback ("flute")
- `DEFAULT_SPEED`: Default playback speed for music (0.88)

**Data Structures**:
- `level_music`: Dictionary mapping level numbers to music track names
  - Level 1 → "quiet_forest"
  - Level 2 → "phantom"
  - Extensible for additional levels

**Signals**:
- `player_died(cause)`: Emitted when player dies, includes death cause string

**Public Functions**:

### Level & Music Management
- `play_level_music(level_number: int)`: Plays music for specified level
  - Looks up track from level_music dictionary
  - Falls back to "quiet_forest" if level not found
  - Uses DEFAULT_SOUNDFONT and DEFAULT_SPEED

- `start_game()`: Initializes first level
  - Loads level_01.tscn
  - Plays level 1 music
  - Displays title card and tutorial prompt

- `next_level()`: Transitions to next level
  - Extracts current level number from scene name
  - Increments and loads next level scene
  - Automatically plays appropriate music for new level

- `end_game()`: Displays end game message

### Player Lifecycle
- `kill_player(cause)`: Handles player death
  - Plays death sound based on cause
  - Emits player_died signal
  - Waits 2 seconds
  - Returns to main menu

- `play_death_sound(cause)`: Plays appropriate sound for death type
  - Currently handles 'FALL' cause

**Usage Examples**:
```gdscript
# Trigger level transition
GameManager.next_level()

# Add music for new level
GameManager.level_music[4] = "ww_theme"

# Kill player with specific cause
GameManager.kill_player('FALL')
```

---

## System Integration

**Music System Flow**:
1. GameManager determines which level is being played
2. GameManager looks up music track from level_music dictionary
3. GameManager calls SoundManager.play_music() with track and settings
4. SoundManager handles actual MIDI playback via MidiPlayer

**Key Design Decisions**:
- **Separation of Concerns**: GameManager handles game logic and level-music associations; SoundManager handles audio mechanics
- **Fallback Strategy**: Undefined levels default to "quiet_forest" to prevent audio failures
- **Centralized Configuration**: Music settings (soundfont, speed) defined as constants for easy adjustment
- **Extensibility**: New levels can be added simply by extending the level_music dictionary

**Adding New Levels**:
```gdscript
# In game_manager.gd
var level_music = {
    1: "quiet_forest",
    2: "phantom",
    3: "ww_theme",      # Add new level
    4: "menu"           # Add another level
}
```

**Adding New Music Tracks**:
```gdscript
# In sound_manager.gd
var music_tracks = {
    "quiet_forest": "res://assets/audio/music/Quiet_Forest.mid",
    "new_track": "res://assets/audio/music/NewTrack.mid"  # Add new track
}

# Then reference in game_manager.gd
GameManager.level_music[5] = "new_track"
```
