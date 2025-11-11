# Data Schema - Save the Christmas

**Related Documentation**:
- **ARCHITECTURE-MASTER.md** - System overview and architecture
- **GAME-RULES.md** - Game mechanics and progression logic
- **MILESTONES-AND-TASKS.md** - Implementation tasks

---

## Overview
This document defines all data structures used in "Save the Christmas" including level definitions, save data format, and runtime class structures.

---

## 1. Level Definition File: levels.json

### File Location
`res://data/levels.json`

### Structure
```json
{
  "version": "1.0",
  "total_levels": 20,
  "levels": [
    {
      "level_id": 1,
      "name": "Christmas Tree",
      "image_path": "res://assets/levels/level_01.png",
      "thumbnail_path": "res://assets/levels/thumbnails/level_01_thumb.png",
      "puzzle_type": "spiral_twist",
      "difficulty_configs": {
        "easy": { "ring_count": 3 },
        "normal": { "ring_count": 5 },
        "hard": { "ring_count": 7 }
      },
      "hint_limit": 3,
      "tags": ["tree", "festive", "outdoor"]
    },
    {
      "level_id": 2,
      "name": "Cozy Fireplace",
      "image_path": "res://assets/levels/level_02.png",
      "thumbnail_path": "res://assets/levels/thumbnails/level_02_thumb.png",
      "puzzle_type": "rectangle_jigsaw",
      "difficulty_configs": {
        "easy": {
          "rows": 2,
          "columns": 3,
          "tile_count": 6
        },
        "normal": {
          "rows": 3,
          "columns": 4,
          "tile_count": 12
        },
        "hard": {
          "rows": 5,
          "columns": 6,
          "tile_count": 30
        }
      },
      "hint_limit": 3,
      "tags": ["indoor", "warm", "festive"]
    }
    // ... levels 3-20 follow same structure (odd=spiral, even=rectangle)
  ]
}
```

### Field Definitions

#### Root Level Fields
- **version** (string): Schema version for backwards compatibility
- **total_levels** (int): Total number of levels in game (20 for MVP)
- **levels** (array): Array of level objects

#### Level Object Fields
- **level_id** (int): Unique identifier (1-20), used for progression
- **name** (string): Display name of the level (e.g., "Christmas Tree")
- **image_path** (string): Path to full-resolution source image (2048×2048px PNG, circular for spiral puzzles)
- **thumbnail_path** (string): Path to thumbnail for level selection (512×512px PNG)
- **puzzle_type** (string): Type of puzzle mechanics - "rectangle_jigsaw" or "spiral_twist"
- **difficulty_configs** (object): Configuration for each difficulty
  - Rectangle Jigsaw: {rows, columns, tile_count}
  - Spiral Twist: {ring_count}
- **hint_limit** (int, optional): Maximum hints allowed (default: 3)
- **tags** (array, optional): Category tags for future filtering/searching

### Validation Rules
- `level_id` must be sequential (1, 2, 3, ..., 20)
- Rectangle Jigsaw: `tile_count` must equal `rows × columns`
- Spiral Twist: `ring_count` must be 3-7
- `image_path` must point to existing asset
- `difficulty_configs` must contain all three difficulties (easy, normal, hard)
- All images must be square aspect ratio (1:1)
- Odd-numbered levels typically use "spiral_twist", even use "rectangle_jigsaw"

---

## 2. Save Data File: save_data.cfg

### File Location
`user://save_data.cfg` (platform-specific user directory)

### Format
Godot ConfigFile format (INI-style)

### Structure
```ini
[metadata]
version = "1.0"
last_played_timestamp = 1703123456
game_install_date = 1703000000

[progress]
current_level = 5
highest_level_unlocked = 5
total_levels_completed = 4

[stars]
level_1_easy = true
level_1_normal = true
level_1_hard = true
level_2_easy = true
level_2_normal = true
level_2_hard = false
# ... continues for all 20 levels × 3 difficulties (60 entries total)

[settings]
sound_enabled = true
music_enabled = true
vibrations_enabled = true
music_volume = 0.7
sound_volume = 0.8

[statistics]
total_playtime_seconds = 3600
total_swaps_made = 450
total_hints_used = 12
levels_completed_count = 4
total_stars_earned = 7
```

### Section Descriptions

#### [metadata]
- **version** (string): Save data format version
- **last_played_timestamp** (int): Unix timestamp of last gameplay
- **game_install_date** (int): Unix timestamp of first game launch

#### [progress]
- **current_level** (int): Last level player was on (1-20)
- **highest_level_unlocked** (int): Highest level unlocked (1-20)
- **total_levels_completed** (int): Count of levels with at least 1 star

#### [stars]
- **level_N_easy** (bool): True if Easy difficulty completed for level N
- **level_N_normal** (bool): True if Normal difficulty completed
- **level_N_hard** (bool): True if Hard difficulty completed
- Format: 60 entries total (20 levels × 3 difficulties)

#### [settings]
- **sound_enabled** (bool): Sound effects toggle
- **music_enabled** (bool): Background music toggle
- **vibrations_enabled** (bool): Haptic feedback toggle
- **music_volume** (float): Music volume (0.0 to 1.0)
- **sound_volume** (float): Sound effects volume (0.0 to 1.0)

#### [statistics] (Optional)
- **total_playtime_seconds** (int): Total time spent in game
- **total_swaps_made** (int): Total tile swaps across all levels
- **total_hints_used** (int): Total hints used
- **levels_completed_count** (int): Levels completed at any difficulty
- **total_stars_earned** (int): Sum of all stars earned (0-60)

---

## 3. In-Memory Data Structures

### LevelData Class
```gdscript
class_name LevelData
extends Resource

## Level definition loaded from levels.json
@export var level_id: int
@export var name: String
@export var image_path: String
@export var thumbnail_path: String
@export var puzzle_type: String
@export var difficulty_configs: Dictionary  # {easy: {}, normal: {}, hard: {}}
@export var hint_limit: int = 3
@export var tags: Array[String] = []

## Runtime computed properties
var image_texture: Texture2D  # Loaded dynamically
var thumbnail_texture: Texture2D  # Loaded dynamically

func get_difficulty_config(difficulty: String) -> Dictionary
func get_tile_count(difficulty: String) -> int
func get_grid_size(difficulty: String) -> Vector2i
```

### ProgressData Class
```gdscript
class_name ProgressData
extends Resource

## Player progression state
var current_level: int = 1
var highest_level_unlocked: int = 1
var stars: Dictionary = {}  # {level_id: {easy: bool, normal: bool, hard: bool}}

func is_level_unlocked(level_id: int) -> bool

## KEY IMPLEMENTATION EXAMPLE: Difficulty unlock logic
func is_difficulty_unlocked(level_id: int, difficulty: String) -> bool:
    """Check if specific difficulty is unlocked for level"""
    if not is_level_unlocked(level_id):
        return false

    match difficulty:
        "easy":
            return true  # Easy always unlocked if level unlocked
        "normal":
            return get_star(level_id, "easy")  # Unlocked after Easy completion
        "hard":
            return get_star(level_id, "normal")  # Unlocked after Normal completion
        _:
            return false

func get_star(level_id: int, difficulty: String) -> bool
func set_star(level_id: int, difficulty: String, earned: bool) -> void
func get_star_count(level_id: int) -> int
func get_total_stars() -> int
func unlock_next_level() -> void
```

### PuzzleState Class
```gdscript
class_name PuzzleState
extends Resource

## Current puzzle gameplay state
var level_id: int
var difficulty: String
var grid_size: Vector2i  # (rows, columns)
var tiles: Array[Tile] = []  # Current tile arrangement
var selected_tile_index: int = -1  # Currently selected tile (-1 if none)
var swap_count: int = 0  # Number of swaps made
var hints_used: int = 0  # Hints used this session
var is_solved: bool = false

## KEY IMPLEMENTATION EXAMPLE: Puzzle validation
func is_puzzle_solved() -> bool:
    """Check if all tiles are in correct positions"""
    for tile in tiles:
        if not tile.is_correct():
            return false
    return true

func get_tile_at_position(position: Vector2i) -> Tile
```

### Tile Class (Rectangle Jigsaw)
```gdscript
class_name Tile
extends Resource

## Individual puzzle tile
var tile_id: int  # Unique identifier (0 to tile_count-1)
var current_position: Vector2i  # Current grid position (row, col)
var correct_position: Vector2i  # Solution position
var texture_region: Rect2  # Region of source image (x, y, width, height)

func is_correct() -> bool
func swap_positions(other_tile: Tile) -> void
```

### SpiralRing Class (Spiral Twist)
```gdscript
class_name SpiralRing
extends Resource

## Individual ring in spiral puzzle
var ring_index: int  # Ring number from center (0=innermost)
var current_angle: float  # Current rotation in degrees
var correct_angle: float  # Target angle (always 0.0)
var angular_velocity: float  # Rotation speed in degrees/second
var inner_radius: float  # Inner circle radius in pixels
var outer_radius: float  # Outer circle radius in pixels
var is_merged: bool  # Whether ring is locked
var merged_ring_ids: Array[int]  # Rings merged into this one

## KEY METHODS
func is_angle_correct(threshold: float = 1.0) -> bool:
    """Check if within SPIRAL_ROTATION_SNAP_ANGLE"""
    return abs(current_angle - correct_angle) <= threshold

func can_merge_with(other_ring: SpiralRing) -> bool:
    """Check merge conditions:
    - Both not merged
    - Adjacent (indices differ by 1)
    - Angle difference ≤ 5.0°
    - Velocity difference ≤ 10.0°/s
    """

func merge_with(other_ring: SpiralRing) -> void:
    """Merge two rings:
    - Average angles and velocities
    - Mark both as merged
    - Track merged ring IDs
    - Merged ring continues rotating unless it's the outermost (static) ring
    """

func update_rotation(delta: float) -> void:
    """Physics update per frame:
    - Apply angular velocity to current angle
    - Apply deceleration (200.0°/s²)
    - Stop when below 1.0°/s
    """

func _normalize_angle(angle: float) -> float:
    """Convert to [-180, 180] range"""
```

### SpiralPuzzleState Class
```gdscript
class_name SpiralPuzzleState
extends Resource

## Current spiral puzzle state
var level_id: int
var difficulty: String
var ring_count: int  # Total rings (3-7)
var rings: Array[SpiralRing]  # All ring objects
var active_ring_count: int  # Number of unmerged rings
var rotation_count: int  # Total rotations made
var hints_used: int  # Hints consumed
var is_solved: bool  # Completion flag
var puzzle_radius: float  # Max radius (450.0 pixels)

## KEY IMPLEMENTATION EXAMPLE: Spiral puzzle validation
func is_puzzle_solved() -> bool:
    """Puzzle solved when ≤1 active ring remains"""
    return active_ring_count <= 1

func update_physics(delta: float) -> void:
    """Update all rings' rotations each frame"""
    for ring in rings:
        if not ring.is_merged:
            ring.update_rotation(delta)

func check_and_merge_rings() -> bool:
    """Detect and perform ring merges
    Returns true if any merge occurred"""
    for i in range(rings.size() - 1):
        if rings[i].can_merge_with(rings[i + 1]):
            rings[i].merge_with(rings[i + 1])
            active_ring_count -= 1
            return true
    return false

func get_ring_at_position(touch_pos: Vector2, center: Vector2) -> SpiralRing:
    """Hit detection for rings"""

func set_ring_velocity(ring_index: int, velocity: float) -> void:
    """Apply flick momentum"""

func rotate_ring(ring_index: int, angle_delta: float) -> void:
    """Direct drag rotation"""

func use_hint() -> bool:
    """Snap random incorrect ring to correct angle"""
```

---

## 4. Configuration Constants

### GameConstants AutoLoad
```gdscript
extends Node

## File paths
const LEVELS_DATA_PATH = "res://data/levels.json"
const SAVE_DATA_PATH = "user://save_data.cfg"

## Game settings
const TOTAL_LEVELS = 20
const MAX_STARS_PER_LEVEL = 3
const DEFAULT_HINT_LIMIT = 3

## Grid configurations defined in levels.json difficulty_configs
# Easy: 2×3 (6 tiles), Normal: 3×4 (12 tiles), Hard: 5×6 (30 tiles)

## Puzzle mechanics - Rectangle Jigsaw
const TILE_SWAP_DURATION = 0.3  # seconds
const TILE_SELECTION_SCALE = 1.05
const HINT_ANIMATION_DURATION = 0.5

## Puzzle mechanics - Spiral Twist
const SPIRAL_RING_BORDER_WIDTH = 4  # pixels
const SPIRAL_MERGE_ANGLE_THRESHOLD = 5.0  # degrees
const SPIRAL_MERGE_VELOCITY_THRESHOLD = 10.0  # degrees per second
const SPIRAL_ANGULAR_DECELERATION = 200.0  # degrees/s²
const SPIRAL_MAX_ANGULAR_VELOCITY = 720.0  # degrees per second
const SPIRAL_MIN_VELOCITY_THRESHOLD = 1.0  # Stop below this
const SPIRAL_ROTATION_SNAP_ANGLE = 1.0  # Snap when within this angle

## Spiral ring counts per difficulty
const SPIRAL_RINGS_EASY = 3
const SPIRAL_RINGS_NORMAL = 5
const SPIRAL_RINGS_HARD = 7

## Audio settings
const DEFAULT_MUSIC_VOLUME = 0.7
const DEFAULT_SOUND_VOLUME = 0.8

## Level image specifications
const LEVEL_IMAGE_SIZE = 2048  # 2048×2048 pixels
const THUMBNAIL_SIZE = 512  # 512×512 pixels

## Enums
enum Difficulty { EASY, NORMAL, HARD }
enum PuzzleType { RECTANGLE_JIGSAW, SPIRAL_TWIST }

## Helper functions for difficulty string conversion
static func difficulty_to_string(diff: Difficulty) -> String
static func string_to_difficulty(diff_str: String) -> Difficulty
```

---

## 5. Data Flow Diagrams

### Level Loading Flow
```
Game Start
    ↓
LevelManager.load_levels()
    ↓
Parse levels.json
    ↓
Create LevelData objects (1-20)
    ↓
Store in LevelManager.levels array
    ↓
Load thumbnails for Level Selection
```

### Progress Save Flow
```
Level Completed
    ↓
ProgressManager.set_star(level_id, difficulty, true)
    ↓
ProgressManager.unlock_next_level()
    ↓
ProgressManager.save_progress()
    ↓
Write to user://save_data.cfg
```

### Gameplay Data Flow
```
Start Level
    ↓
LevelManager.get_level(level_id) → LevelData
    ↓
PuzzleManager.generate_puzzle(LevelData, difficulty) → PuzzleState
    ↓
PuzzleManager.scramble_tiles(PuzzleState)
    ↓
GameplayScreen displays PuzzleState
    ↓
Player swaps tiles → Update PuzzleState
    ↓
Check PuzzleState.is_puzzle_solved()
    ↓
If solved → Level Complete Screen
```

---

## 6. Save Data Migration

### Versioning Strategy
- Save data includes version field ("1.0", "1.1", etc.)
- On load, check version and apply migrations if needed
- Missing fields use default values
- Corrupted save data triggers reset with user prompt

### Backward Compatibility
- Support loading save data from previous versions
- Graceful degradation if save data version > app version
- Implement migration functions in ProgressManager

---

## 7. Asset Naming Conventions

### Level Images
- **Full Images**: `level_01.png` to `level_20.png`
  - Location: `res://assets/levels/`
  - Size: 2048×2048 pixels, PNG format
- **Thumbnails**: `level_01_thumb.png` to `level_20_thumb.png`
  - Location: `res://assets/levels/thumbnails/`
  - Size: 512×512 pixels, PNG format

### Audio Files
- **Music**: `christmas_music_01.ogg`, `christmas_music_02.ogg`
- **Sound Effects**:
  - `tile_select.ogg`
  - `tile_swap.ogg`
  - `level_complete.ogg`
  - `button_click.ogg`
  - `hint_used.ogg`

---

## 8. Error Handling Requirements

### Required Error Handling
- **Missing Level Data**: Validate level_id ranges, handle missing levels gracefully
- **Corrupted Save Data**: Detect corrupted ConfigFile, prompt user to reset
- **Missing Assets**: Check ResourceLoader.exists(), provide fallback placeholder assets
- **Invalid Data**: Validate JSON structure, grid configurations, file paths

Implementation details in manager scripts (LevelManager, ProgressManager, PuzzleManager).

---

This data schema provides the complete foundation for all game data structures in "Save the Christmas".
