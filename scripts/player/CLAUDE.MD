# Character System Documentation

## Architecture Overview

The character system uses an inheritance hierarchy to support both player-controlled and NPC characters:

```
CharacterBody2D
└── Character (character.gd)
    ├── Player (player.tscn) - P1 with default input_prefix="p1"
    ├── Player2 (player2.tscn) - P2 with input_prefix="p2"
    └── NPC (npc.gd)
        └── Chris (chris.gd) - Simple AI that follows player
```

## Core Classes

### Character (character.gd)
**Base class for all controllable characters (players and NPCs)**

**Key Features**:
- Complete 2D platformer physics with gravity, jumping, and movement
- Inventory system with item collection, dropping, and rotation
- Held item visual display with sprite flipping
- Animation handling (idle, walk, jump)
- Collision with pushable objects
- Death handling with fall detection

**Exported Variables**:
- `input_prefix`: String = "p1" - Determines which input actions to listen to (e.g., "p1_left", "p2_jump")
- `input_enabled`: bool = false - Whether this character responds to input
- `do_item_prompt`: bool = false - Whether to show pickup prompt on first item
- `group`: String = "npc" - Which group to add the character to ("player", "npc", etc.)

**Constants**:
- `SPEED`: 300.0 - Horizontal movement speed
- `JUMP_VELOCITY`: -500.0 - Jump strength
- `DEATH_Y_THRESHOLD`: 2000 - Fall death boundary
- `MAX_INVENTORY_SIZE`: 2 - Max different item types
- `MAX_STACK_SIZE`: 99 - Max quantity per item type

**Virtual Methods**:
- `get_movement_direction() -> float`: Returns -1 to 1 for movement. Default implementation reads from input actions "{input_prefix}_left" and "{input_prefix}_right". Override this for NPCs.

**Key Methods**:
- `collect_item(item_id: String)` - Add item to inventory
- `drop_item(item_id: String)` - Drop one instance of an item
- `rotate_held_item()` - Cycle through inventory items
- `die(cause)` - Handle character death

**Input Actions Used** (with input_prefix):
- `{prefix}_left` / `{prefix}_right` - Movement
- `{prefix}_jump` - Jumping
- `{prefix}_drop_item` - Drop current held item
- `{prefix}_rotate_held_item` - Cycle through inventory

### NPC (npc.gd)
**Base class for non-player characters**

Extends Character and provides programmatic movement control instead of input-based control.

**Key Properties**:
- `movement_direction`: float = 0.0 - Set this to -1, 0, or 1 to control NPC movement
- `input_enabled` = false (set in _ready)

**Overridden Methods**:
- `get_movement_direction()` - Returns `movement_direction` variable instead of reading input

**Usage Pattern**:
```gdscript
extends NPC

func _physics_process(delta):
	# Set movement_direction based on AI logic
	if should_move_left():
		movement_direction = -1.0
	elif should_move_right():
		movement_direction = 1.0
	else:
		movement_direction = 0.0

	# Call parent to handle physics, animations, etc.
	super._physics_process(delta)
```

### Chris (chris.gd)
**Example NPC implementation with simple follow AI**

Extends NPC with basic behavior: walks toward player until within `STOP_DISTANCE`.

**Properties**:
- `STOP_DISTANCE`: 200.0 - How close to get to player before stopping
- `player`: Character - Reference to player found via "player" group

**Behavior**:
- Finds player in _ready() using `get_tree().get_first_node_in_group("player")`
- Each frame, calculates distance to player
- Sets `movement_direction = -1.0` if too far, `0.0` if close enough
- Calls `super._physics_process()` to execute movement

## Scene Structure

### Player Scenes
**player.tscn**:
- Instance of character.tscn
- `input_enabled = true`
- `input_prefix = "p1"` (default)
- `group = "player"`
- `do_item_prompt = true`

**player2.tscn**:
- Instance of character.tscn with custom sprite
- `input_enabled = true`
- `input_prefix = "p2"`
- `group = "player"`

### NPC Scenes
**chris.tscn**:
- Uses chris.gd script
- Inherits from NPC

## Creating New Characters

### Adding a New Player (P3, P4, etc.):
1. Create new scene inheriting from `res://scenes/player/character.tscn`
2. Set exported variables:
   - `input_enabled = true`
   - `input_prefix = "p3"` (or appropriate prefix)
   - `group = "player"`
3. Create corresponding input actions in Project Settings (p3_left, p3_right, p3_jump, etc.)
4. Optionally customize sprite/animations

### Adding a New NPC:
1. Create new script extending NPC
2. Override `_physics_process(delta)` to implement AI behavior
3. Set `movement_direction` based on desired behavior
4. Call `super._physics_process(delta)` to execute movement
5. Create scene file using your new script

Example:
```gdscript
extends NPC

var patrol_direction: float = 1.0

func _ready():
	super._ready()

func _physics_process(delta):
	# Simple patrol AI
	if is_on_wall():
		patrol_direction *= -1

	movement_direction = patrol_direction
	super._physics_process(delta)
```

## Input System

The input system uses prefixed action names to support multiple players:
- Define actions in Project Settings → Input Map
- Name format: `{prefix}_{action}` (e.g., "p1_jump", "p2_left")
- Character class automatically uses the correct prefix based on `input_prefix` variable
- NPCs don't use input system (input_enabled = false)

## Inventory System

All characters share the same inventory implementation:
- Dictionary mapping item_id (String) → quantity (int)
- Max 2 different item types, max 99 of each type
- When picking up new type at capacity, oldest item is dropped
- Items are visually displayed when held
- Rotation system cycles through available items

## Dialog System

The dialog system allows NPCs to display text in speech bubbles that follow characters on screen.

### Architecture

**DialogBox (dialog_box.tscn / dialog_box.gd)**:
- Control node with PanelContainer, Label, and AnimationPlayer
- Automatically positions above target character
- Auto-resizes to fit text content
- Fade in/out animations

**NPC Integration**:
- NPC base class provides `dialog_box` variable and `DialogBox` constant
- NPCs instantiate and manage their own dialog box instances
- Dialog boxes are added as children of the NPC for automatic cleanup

### Key DialogBox Methods

**`show_dialog(text: String, character: Node2D = null)`**
- Displays dialog box with given text
- If character provided, positions box above character and follows them
- Auto-fades in over `FADE_DURATION` (0.2s)
- If already open, updates text without re-animating

**`hide_dialog()`**
- Fades out and hides the dialog box
- Clears target character reference

### Important Implementation Details

**Async/Timing Considerations**:
The dialog box uses regular variables (not `@onready`) that are initialized in `_ready()`. When instantiating and using a dialog box, you MUST wait for initialization:

```gdscript
# In your NPC script
var dialog_box: Control = null
var dialog_ready: bool = false

func _setup_dialog_box():
	dialog_box = DialogBox.instantiate()
	add_child(dialog_box)
	# CRITICAL: Wait for node to be fully initialized
	await get_tree().process_frame
	dialog_ready = true
```

**When calling `show_dialog()`**, ensure the dialog box is ready:
```gdscript
func _show_dialog_when_ready():
	# Wait until dialog_ready flag is set
	while not dialog_ready:
		await get_tree().process_frame

	if dialog_box:
		dialog_box.show_dialog("Hello!", self)
```

**Why This Pattern?**:
- `@onready` variables are only initialized after `_ready()` completes
- If you call `show_dialog()` immediately after `instantiate()`, the internal nodes will be null
- Waiting one frame after `add_child()` ensures `_ready()` has completed
- Using a ready flag prevents race conditions when called from `_physics_process()`

### Usage Example (Chris NPC)

```gdscript
extends NPC

const STOP_DISTANCE: float = 200.0

var player: Character = null
var has_reached_player: bool = false
var dialog_ready: bool = false

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("player")
	_setup_dialog_box()

func _setup_dialog_box():
	dialog_box = DialogBox.instantiate()
	add_child(dialog_box)
	await get_tree().process_frame
	dialog_ready = true

func _physics_process(delta):
	if player and not has_reached_player:
		var distance_to_player = global_position.distance_to(player.global_position)

		if distance_to_player > STOP_DISTANCE:
			movement_direction = -1.0
		else:
			movement_direction = 0.0
			has_reached_player = true
			_show_dialog_when_ready()

	super._physics_process(delta)

func _show_dialog_when_ready():
	while not dialog_ready:
		await get_tree().process_frame

	dialog_box.show_dialog("Hey! I finally caught up to you!", self)
```

### Constants and Configuration

**DialogBox Constants**:
- `FADE_DURATION`: 0.2 - Fade animation duration in seconds
- `OFFSET_ABOVE_CHARACTER`: Vector2(0, -60) - Vertical offset above character

**Scene Structure** (dialog_box.tscn):
```
DialogBox (Control)
├── PanelContainer
│   └── MarginContainer
│       └── Label
└── AnimationPlayer
```
