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
