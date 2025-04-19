# Platformer Game Project Summary

## Project Foundation
- Godot 4.4 project
- Standard directory structure (scenes, scripts, assets) with subdirectories (player, enemies, levels, etc.)

## Player Character
- CharacterBody2D with sprite and collision shape
- Movement: gravity, left/right controls, jumping
- Sprite flips to face movement direction
- Jump animation plays when airborne (with time threshold to prevent flicker on uneven terrain)
- Added to "player" group for enemy detection

## Level Design
- Basic level scene (level_01.tscn)
- Parallax scrolling background
- TileMap with TileSet for ground/platforms
- Camera2D with smooth follow script

## Squirrel NPC
- CharacterBody2D with AnimatedSprite2D
- State machine with three states (IDLE, WALKING, FLEEING)
- Timer-based state transitions with random durations
- Wall collision detection and direction reversal
- Sprite flipping based on movement direction
- Player proximity detection (flees when player gets too close)
- Returns to normal behavior when player moves away
- Faster movement speed when fleeing

## Next Steps
- Player-squirrel interaction (Area2D)
- Item/inventory system
- Trading mechanics for puzzle (player trades food for key)
- Adding proper idle animation for squirrel
- Custom input actions (replace default ui_* actions)
- Consider edge detection for squirrel platform movement

## Goal Context
- Implement puzzle where player trades food with squirrel for key/item