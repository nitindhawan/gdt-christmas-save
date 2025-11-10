# Data Schema - Save the Christmas

## Overview
This document defines all data structures used in "Save the Christmas" including level definitions, save data format, and configuration files.

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
      "name": "Cozy Fireplace",
      "image_path": "res://assets/levels/level_01.png",
      "thumbnail_path": "res://assets/levels/thumbnails/level_01_thumb.png",
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
    },
    {
      "level_id": 2,
      "name": "Snowy Village",
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
      "tags": ["outdoor", "snow", "village"]
    }
    // ... levels 3-20 follow same structure
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
- **name** (string): Display name of the level (e.g., "Cozy Fireplace")
- **image_path** (string): Path to full-resolution source image (2048×2048px PNG)
- **thumbnail_path** (string): Path to thumbnail for level selection (512×512px PNG)
- **puzzle_type** (string): Type of puzzle mechanics
  - MVP: "rectangle_jigsaw"
  - Future: "spiral_twist", "hybrid"
- **difficulty_configs** (object): Configuration for each difficulty level
  - **easy**, **normal**, **hard** (objects):
    - **rows** (int): Number of rows in tile grid
    - **columns** (int): Number of columns in tile grid
    - **tile_count** (int): Total tiles (rows × columns) - for validation
- **hint_limit** (int, optional): Maximum hints allowed (default: 3)
- **tags** (array, optional): Category tags for future filtering/searching

### Validation Rules
- `level_id` must be sequential (1, 2, 3, ..., 20)
- `tile_count` must equal `rows × columns`
- `image_path` must point to existing asset
- `difficulty_configs` must contain all three difficulties (easy, normal, hard)
- All images must be square aspect ratio (1:1)

---

## 2. Save Data File: save_data.cfg

### File Location
`user://save_data.cfg` (platform-specific user directory)

### File Format
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
level_3_easy = true
level_3_normal = false
level_3_hard = false
level_4_easy = true
level_4_normal = false
level_4_hard = false
level_5_easy = false
level_5_normal = false
level_5_hard = false

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

#### [statistics] (Optional, for analytics)
- **total_playtime_seconds** (int): Total time spent in game
- **total_swaps_made** (int): Total tile swaps across all levels
- **total_hints_used** (int): Total hints used
- **levels_completed_count** (int): Levels completed at any difficulty
- **total_stars_earned** (int): Sum of all stars earned (0-60)

---

## 3. In-Memory Data Structures

### LevelData Class (GDScript)
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

func get_difficulty_config(difficulty: String) -> Dictionary:
    """Returns configuration for specified difficulty"""
    return difficulty_configs.get(difficulty, {})

func get_tile_count(difficulty: String) -> int:
    """Returns total tile count for difficulty"""
    var config = get_difficulty_config(difficulty)
    return config.get("tile_count", 0)

func get_grid_size(difficulty: String) -> Vector2i:
    """Returns (rows, columns) for difficulty"""
    var config = get_difficulty_config(difficulty)
    return Vector2i(config.get("rows", 2), config.get("columns", 3))
```

### ProgressData Class (GDScript)
```gdscript
class_name ProgressData
extends Resource

## Player progression state
var current_level: int = 1
var highest_level_unlocked: int = 1
var stars: Dictionary = {}  # {level_id: {easy: bool, normal: bool, hard: bool}}

func is_level_unlocked(level_id: int) -> bool:
    """Check if level is unlocked"""
    return level_id <= highest_level_unlocked

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

func get_star(level_id: int, difficulty: String) -> bool:
    """Get star status for level and difficulty"""
    if level_id not in stars:
        return false
    return stars[level_id].get(difficulty, false)

func set_star(level_id: int, difficulty: String, earned: bool) -> void:
    """Set star status for level and difficulty"""
    if level_id not in stars:
        stars[level_id] = {"easy": false, "normal": false, "hard": false}
    stars[level_id][difficulty] = earned

func get_star_count(level_id: int) -> int:
    """Get total stars earned for level (0-3)"""
    if level_id not in stars:
        return 0
    var count = 0
    if stars[level_id].get("easy", false): count += 1
    if stars[level_id].get("normal", false): count += 1
    if stars[level_id].get("hard", false): count += 1
    return count

func get_total_stars() -> int:
    """Get total stars earned across all levels"""
    var total = 0
    for level_id in stars:
        total += get_star_count(level_id)
    return total

func unlock_next_level() -> void:
    """Unlock the next level if possible"""
    highest_level_unlocked = mini(highest_level_unlocked + 1, 20)
```

### PuzzleState Class (GDScript)
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

func is_puzzle_solved() -> bool:
    """Check if all tiles are in correct positions"""
    for tile in tiles:
        if not tile.is_correct():
            return false
    return true

func get_tile_at_position(position: Vector2i) -> Tile:
    """Get tile at grid position (row, col)"""
    for tile in tiles:
        if tile.current_position == position:
            return tile
    return null
```

### Tile Class (GDScript)
```gdscript
class_name Tile
extends Resource

## Individual puzzle tile
var tile_id: int  # Unique identifier (0 to tile_count-1)
var current_position: Vector2i  # Current grid position (row, col)
var correct_position: Vector2i  # Solution position
var texture_region: Rect2  # Region of source image (x, y, width, height)

func is_correct() -> bool:
    """Check if tile is in correct position"""
    return current_position == correct_position

func swap_positions(other_tile: Tile) -> void:
    """Swap positions with another tile"""
    var temp_position = current_position
    current_position = other_tile.current_position
    other_tile.current_position = temp_position
```

---

## 4. Configuration Constants

### GameConstants Class (GDScript AutoLoad)
```gdscript
extends Node

## File paths
const LEVELS_DATA_PATH = "res://data/levels.json"
const SAVE_DATA_PATH = "user://save_data.cfg"

## Game settings
const TOTAL_LEVELS = 20
const MAX_STARS_PER_LEVEL = 3
const DEFAULT_HINT_LIMIT = 3

## Difficulty configurations (default if not in levels.json)
const DIFFICULTY_GRIDS = {
    "easy": {"rows": 2, "columns": 3},
    "normal": {"rows": 3, "columns": 4},
    "hard": {"rows": 5, "columns": 6}
}

## Puzzle mechanics
const TILE_SWAP_DURATION = 0.3  # seconds
const TILE_SELECTION_SCALE = 1.05
const HINT_ANIMATION_DURATION = 0.5

## Audio settings
const DEFAULT_MUSIC_VOLUME = 0.7
const DEFAULT_SOUND_VOLUME = 0.8

## Level image specifications
const LEVEL_IMAGE_SIZE = 2048  # 2048×2048 pixels
const THUMBNAIL_SIZE = 512  # 512×512 pixels

## Enums
enum Difficulty { EASY, NORMAL, HARD }
enum PuzzleType { RECTANGLE_JIGSAW, SPIRAL_TWIST }

## Difficulty string mappings
static func difficulty_to_string(diff: Difficulty) -> String:
    match diff:
        Difficulty.EASY: return "easy"
        Difficulty.NORMAL: return "normal"
        Difficulty.HARD: return "hard"
        _: return "easy"

static func string_to_difficulty(diff_str: String) -> Difficulty:
    match diff_str.to_lower():
        "easy": return Difficulty.EASY
        "normal": return Difficulty.NORMAL
        "hard": return Difficulty.HARD
        _: return Difficulty.EASY
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

## 6. Save Data Migration Strategy

### Versioning
- Save data includes version field ("1.0", "1.1", etc.)
- On load, check version and apply migrations if needed

### Example Migration (v1.0 → v1.1)
```gdscript
func migrate_save_data(config: ConfigFile, from_version: String, to_version: String):
    if from_version == "1.0" and to_version == "1.1":
        # Example: Add new settings fields
        if not config.has_section_key("settings", "language"):
            config.set_value("settings", "language", "en")

        # Update version
        config.set_value("metadata", "version", "1.1")
        config.save(SAVE_DATA_PATH)
```

### Backward Compatibility
- If save data version > app version, show warning but attempt to load
- Missing fields use default values
- Corrupted save data: Prompt user to reset or restore backup

---

## 7. Asset Naming Conventions

### Level Images
- **Full Images**: `level_01.png`, `level_02.png`, ..., `level_20.png`
  - Location: `res://assets/levels/`
  - Size: 2048×2048 pixels, PNG format
- **Thumbnails**: `level_01_thumb.png`, `level_02_thumb.png`, ..., `level_20_thumb.png`
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

## 8. Error Handling

### Missing Level Data
```gdscript
func load_level(level_id: int) -> LevelData:
    if level_id < 1 or level_id > TOTAL_LEVELS:
        push_error("Invalid level_id: %d" % level_id)
        return null

    if level_id not in levels:
        push_error("Level %d not loaded" % level_id)
        return null

    return levels[level_id]
```

### Corrupted Save Data
```gdscript
func load_save_data() -> bool:
    var config = ConfigFile.new()
    var err = config.load(SAVE_DATA_PATH)

    if err != OK:
        push_warning("Save data not found or corrupted. Creating new save.")
        create_default_save_data()
        return false

    # Validate required sections
    if not config.has_section("progress") or not config.has_section("stars"):
        push_warning("Save data missing required sections. Resetting.")
        create_default_save_data()
        return false

    # Load valid save data
    parse_save_data(config)
    return true
```

### Missing Assets
```gdscript
func load_level_image(image_path: String) -> Texture2D:
    if not ResourceLoader.exists(image_path):
        push_error("Level image not found: %s" % image_path)
        return preload("res://assets/ui/missing_image_placeholder.png")

    var texture = load(image_path) as Texture2D
    if texture == null:
        push_error("Failed to load image: %s" % image_path)
        return preload("res://assets/ui/missing_image_placeholder.png")

    return texture
```

---

## 9. Testing Data

### Test Level Definition (test_levels.json)
For development and testing, use a simplified test file:
```json
{
  "version": "1.0",
  "total_levels": 3,
  "levels": [
    {
      "level_id": 1,
      "name": "Test Level 1",
      "image_path": "res://assets/test/test_image_01.png",
      "thumbnail_path": "res://assets/test/test_image_01_thumb.png",
      "puzzle_type": "rectangle_jigsaw",
      "difficulty_configs": {
        "easy": {"rows": 2, "columns": 2, "tile_count": 4},
        "normal": {"rows": 2, "columns": 3, "tile_count": 6},
        "hard": {"rows": 3, "columns": 3, "tile_count": 9}
      },
      "hint_limit": 5
    }
  ]
}
```

### Reset Save Data (Debug Command)
```gdscript
func reset_save_data_debug():
    var dir = DirAccess.open("user://")
    if dir.file_exists("save_data.cfg"):
        dir.remove("save_data.cfg")
    create_default_save_data()
    print("Save data reset to defaults")
```

---

This data schema provides a complete foundation for all game data in "Save the Christmas".
