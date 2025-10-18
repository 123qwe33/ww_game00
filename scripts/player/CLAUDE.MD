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

The dialog system allows NPCs to display text in speech bubbles that follow characters on screen. It uses a distance-based interaction system where any player within range can interact with the dialog.

### Architecture

**DialogBox (dialog_box.tscn / dialog_box.gd)**:
- Control node with PanelContainer, Label, and AnimationPlayer
- Automatically positions above target character
- Auto-resizes to fit text content
- Fade in/out animations
- Uses InteractionArea for automatic player detection and interaction

**InteractionArea (interaction_area.tscn / interaction_area.gd)**:
- Reusable Area2D component for distance-based player interactions
- 200-pixel interaction radius
- Automatically detects all players in "player" group within range
- Handles interaction input from any player (p1_interact, p2_interact, etc.)
- Emits signals: `interact_pressed(player)`, `player_entered(player)`, `player_exited(player)`

**NPC Integration**:
- NPC base class provides `dialog_box` variable and `DialogBox` constant
- NPCs instantiate and manage their own dialog box instances
- Dialog boxes are added as children of the NPC for automatic cleanup

### Key DialogBox Methods

**`show_dialog(text: String, character: Node2D = null, drop_item: bool = false)`**
- Displays single dialog box with given text (no player interaction required)
- If character provided, positions box above character and follows them
- Auto-fades in over `FADE_DURATION` (0.2s)
- If already open, updates text without re-animating
- If `drop_item = true`, character automatically drops their held item when dialog closes

**`show_multiple_dialogs(slides: Array, character: Node2D = null, drop_item: bool = false)`**
- Displays multi-slide dialog that requires player interaction to advance
- `slides`: Array of strings, each representing one dialog slide
- Any player within 200 pixels can press their interact action to advance
- Automatically detects all players (p1, p2, p3, etc.) without manual configuration
- Shows visual indicator: "▼" for more slides, "✓" on final slide
- Automatically closes after last slide is advanced
- If `drop_item = true`, character automatically drops their held item when dialog closes

**`advance()`**
- Advances to the next slide in a multi-slide dialog
- Called automatically by InteractionArea when player in range presses interact
- Can be called manually for programmatic control

**`hide_dialog()`**
- Fades out and hides the dialog box
- Clears target character reference and multi-slide state
- Triggers automatic item drop if `drop_item` was set to true

### Dialog-Triggered Item Drop

The dialog system includes a feature where characters can automatically drop their held item when the dialog closes. This is useful for NPCs that give items to players as part of their interaction.

**How It Works**:
1. When showing a dialog, set the `drop_item` parameter to `true`
2. When the dialog closes (via `hide_dialog()` or after final slide), the system:
   - Checks if the character has a `drop_item()` method
   - Checks if the character has a non-empty `current_held_item`
   - Automatically calls `character.drop_item(current_held_item)`

**Requirements**:
- Character must extend from Character class (has `drop_item()` method and `current_held_item` property)
- Character must have an item in their inventory to drop
- Only drops the currently held item (one instance)

**Usage Example**:
```gdscript
# NPC gives player an item after dialog
func _on_reach_player():
	# Give the NPC an item first
	collect_item("apple")

	# Show dialog with drop_item=true
	dialog_box.show_multiple_dialogs([
		"Hey! I have something for you!",
		"Here, take this apple!"
	], self, true)  # true = drop_item

	# When dialog closes, NPC will automatically drop the apple
```

**Signal Integration**:
The DialogBox emits `dialog_closed(character: Node2D)` signal before triggering the item drop, allowing other systems to react to dialog closure.

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

### Player Interaction Requirements

For interactive dialogs to work, players must have interact actions defined in Project Settings:
- `p1_interact` - Player 1's interact action
- `p2_interact` - Player 2's interact action
- `p3_interact` - Player 3's interact action (if using player 3)
- etc.

The InteractionArea component automatically detects which players are in range and checks their corresponding interact actions. No manual configuration needed - just ensure each player has a matching interact action in Project Settings.

### Usage Examples

**Single Dialog (No Interaction)**:
```gdscript
# Simple one-line dialog that doesn't require player input
dialog_box.show_dialog("Hey! I finally caught up to you!", self)
```

**Multi-Slide Interactive Dialog (Chris NPC)**:
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

	# Multi-slide dialog with player interaction
	# Any player within 200 pixels can press their interact key to advance
	dialog_box.show_multiple_dialogs([
		"Hey! I finally caught up to you!",
		"I've been chasing you for a while!",
		"Nice to see you again!"
	], self)

	# Example with item drop:
	# collect_item("coin")  # Give Chris a coin first
	# dialog_box.show_multiple_dialogs([
	#     "Hey! I have something for you!",
	#     "Here, take this coin!"
	# ], self, true)  # true = drop item on close
```

### Using InteractionArea for Other Interactive Objects

The InteractionArea component is reusable and can be added to any object that needs distance-based player interaction:

**Example: Interactive Sign**:
```gdscript
extends Node2D

const InteractionArea = preload("res://scenes/components/interaction_area.tscn")

var interaction_area: Area2D = null

func _ready():
	# Add interaction area
	interaction_area = InteractionArea.instantiate()
	add_child(interaction_area)

	# Connect to interact signal
	interaction_area.interact_pressed.connect(_on_interact)

	# Optional: Track when players enter/exit range
	interaction_area.player_entered.connect(_on_player_entered)
	interaction_area.player_exited.connect(_on_player_exited)

func _on_interact(player: Character):
	print("Player ", player.input_prefix, " interacted with sign!")
	# Show sign message, trigger event, etc.

func _on_player_entered(player: Character):
	# Could show a prompt like "Press [E] to read"
	pass

func _on_player_exited(player: Character):
	# Hide prompt
	pass
```

**InteractionArea Signals**:
- `interact_pressed(player)` - Emitted when a player in range presses their interact action
- `player_entered(player)` - Emitted when a player enters the interaction radius
- `player_exited(player)` - Emitted when a player exits the interaction radius

**InteractionArea Constants**:
- `INTERACTION_RANGE`: 200.0 - Radius in pixels for interaction detection

### Constants and Configuration

**DialogBox Constants**:
- `FADE_DURATION`: 0.2 - Fade animation duration in seconds
- `OFFSET_ABOVE_CHARACTER`: Vector2(0, -60) - Vertical offset above character

**Scene Structure** (dialog_box.tscn):
```
DialogBox (Control)
├── PanelContainer
│   ├── MarginContainer
│   │   └── Label (main dialog text)
│   └── MarginContainer2
│       └── IndicatorLabel (shows ▼ or ✓)
└── AnimationPlayer
```
