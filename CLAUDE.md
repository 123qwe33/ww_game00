# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Style Guidelines
- **Structure**: `extends` first, followed by @onready/@export vars, constants, variables, functions
- **Naming**: snake_case for variables/functions, UPPER_CASE for constants
- **Class Elements Order**: 1) Constants 2) Exports 3) Variables 4) Ready/Init 5) Process functions 6) Signal handlers 7) Helper functions
- **States**: Use enums for state machines (e.g., `enum State { IDLE, WALKING }`)
- **Types**: Use type hints with Godot types where possible
- **Node References**: Use @onready and @export annotations
- **Whitespace**: Single empty line between logical sections, tabs for indentation
- **Comments**: Brief comments above code blocks explaining purpose
- **Error Handling**: Simple print statements for debugging
- **Animation**: Use AnimatedSprite2D with named animations (e.g., "idle", "walk")

## Common Patterns
- State machines with match statements for transitions
- Physics-based movement with move_and_slide()
- Timer-based behavior changes
- Signal connections for event handling

## Game Management Systems
This project uses autoload singletons for global game systems:
- **GameManager**: Handles level progression, player lifecycle, and level-to-music associations
- **SoundManager**: Centralized audio playback for music, sound effects, and UI sounds

For detailed documentation on these systems, see `/scripts/autoloads/CLAUDE.MD`

**Quick Reference**:
```gdscript
# Trigger level transition (automatically plays level music)
GameManager.next_level()

# Play music for a specific level
GameManager.play_level_music(2)

# Play sound effects
SoundManager.play_fx_sound("land")

# Add music for new levels
GameManager.level_music[3] = "phantom"
```

## Character System
This project uses an inheritance-based character system that supports both player-controlled and NPC characters:
- **Character**: Base class with physics, movement, inventory, and animation systems
- **Player/Player2**: Scene instances configured with different `input_prefix` values (p1, p2)
- **NPC**: Programmatic movement control via `movement_direction` variable
- **Chris**: Example NPC with simple follow-player AI

For detailed documentation on the character system architecture, creating new players/NPCs, and the input system, see `/scripts/player/CLAUDE.MD`

**Quick Reference**:
```gdscript
# Creating a new player (in scene, set exported vars)
input_enabled = true
input_prefix = "p3"  # Must have matching input actions in Project Settings
group = "player"

# Creating a new NPC (extend NPC class)
extends NPC

func _physics_process(delta):
	movement_direction = 1.0  # -1 (left), 0 (stop), 1 (right)
	super._physics_process(delta)  # Let Character handle physics
```
