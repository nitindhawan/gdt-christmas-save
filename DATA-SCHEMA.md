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
      "hint_limit": 0,
      "tags": ["indoor", "warm", "festive"]
    },
    {
      "level_id": 3,
      "name": "Snowy Village",
      "image_path": "res://assets/levels/level_03.png",
      "thumbnail_path": "res://assets/levels/thumbnails/level_03_thumb.png",
      "puzzle_type": "arrow_puzzle",
      "difficulty_configs": {
        "easy": {
          "grid_size": {"x": 5, "y": 4}
        },
        "normal": {
          "grid_size": {"x": 6, "y": 5}
        },
        "hard": {
          "grid_size": {"x": 8, "y": 7}
        }
      },
      "hint_limit": 0,
      "tags": ["village", "snow", "outdoor"]
    }
    // ... levels 4-20 follow 3-way rotation (Level % 3: 1=spiral, 2=rectangle, 0=arrow)
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
- **puzzle_type** (string): Type of puzzle mechanics - "rectangle_jigsaw", "spiral_twist", or "arrow_puzzle"
- **difficulty_configs** (object): Configuration for each difficulty
  - Rectangle Jigsaw: {rows, columns, tile_count}
  - Spiral Twist: {ring_count}
  - Arrow Puzzle: {grid_size: {x: columns, y: rows}}
- **hint_limit** (int, optional): Maximum hints allowed (set to 0, hints removed from game)
- **tags** (array, optional): Category tags for future filtering/searching

### Validation Rules
- `level_id` must be sequential (1, 2, 3, ..., 20)
- Rectangle Jigsaw: `tile_count` must equal `rows × columns`
- Spiral Twist: `ring_count` must be 3-7
- Arrow Puzzle: `grid_size` must be Vector2i (x=columns, y=rows)
- `image_path` must point to existing asset
- `difficulty_configs` must contain all three difficulties (easy, normal, hard)
- All images must be square aspect ratio (1:1)
- Puzzle type determined by level_id % 3: 1=spiral_twist, 2=rectangle_jigsaw, 0=arrow_puzzle

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

### LevelData Class (scripts/level_data.gd - 34 lines)
```gdscript
class_name LevelData
extends Resource

## Level definition loaded from levels.json
@export var level_id: int = 0
@export var name: String = ""
@export var image_path: String = ""
@export var thumbnail_path: String = ""
@export var puzzle_type: String = "rectangle_jigsaw"
@export var difficulty_configs: Dictionary = {}  # {easy: {}, normal: {}, hard: {}}
@export var hint_limit: int = 3
@export var tags: Array[String] = []

## Runtime computed properties
var image_texture: Texture2D = null  # Loaded dynamically
var thumbnail_texture: Texture2D = null  # Loaded dynamically

func get_difficulty_config(difficulty: String) -> Dictionary
func get_tile_count(difficulty: String) -> int
func get_grid_size(difficulty: String) -> Vector2i  # Returns Vector2i(columns, rows)
```

**Note**: LevelManager actually returns Dictionary (not LevelData Resource) from get_level() for compatibility with dynamic generation.

### ProgressManager AutoLoad (scripts/progress_manager.gd - 197 lines)
**Note**: Progress data stored directly in ProgressManager singleton, not separate ProgressData class.

```gdscript
extends Node  # AutoLoad singleton

## Player progression state
var current_level: int = 1
var highest_level_unlocked: int = 1
var stars: Dictionary = {}  # {level_id: {easy: bool, normal: bool, hard: bool}}

## Settings
var sound_enabled: bool = true
var music_enabled: bool = true
var vibrations_enabled: bool = true
var music_volume: float = 0.7
var sound_volume: float = 0.8

## Statistics
var total_playtime_seconds: int = 0
var total_swaps_made: int = 0
var total_hints_used: int = 0

func load_save_data() -> void  # Loads from user://save_data.cfg
func save_progress() -> void   # Saves to ConfigFile
func is_level_unlocked(level_id: int) -> bool

## KEY IMPLEMENTATION: Difficulty unlock logic
func is_difficulty_unlocked(level_id: int, difficulty: String) -> bool:
    """Check if specific difficulty is unlocked for level"""
    if not is_level_unlocked(level_id):
        return false

    match difficulty.to_lower():
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
func get_star_count(level_id: int) -> int  # Returns 0-3
func get_total_stars() -> int
func unlock_next_level() -> void
func reset_progress() -> void
```

### PuzzleState Class (scripts/puzzle_state.gd - 63 lines)
```gdscript
class_name PuzzleState
extends Resource

## Current puzzle gameplay state (Rectangle Jigsaw)
var level_id: int = 0
var difficulty: String = "easy"
var grid_size: Vector2i = Vector2i(3, 2)  # (columns, rows)
var tiles: Array = []  # Array of Tile objects (not typed for compatibility)
var selected_tile_index: int = -1  # Currently selected tile (-1 if none)
var swap_count: int = 0  # Number of swaps made
var hints_used: int = 0  # Hints used this session
var is_solved: bool = false

## KEY IMPLEMENTATION: Puzzle validation
func is_puzzle_solved() -> bool:
    """Check if all tiles are in correct positions"""
    for tile in tiles:
        if tile != null and tile.has_method("is_correct"):
            if not tile.is_correct():
                return false
    return true

func get_tile_at_position(position: Vector2i) -> Resource
func get_tile_by_index(index: int) -> Resource
func swap_tiles(index1: int, index2: int) -> void
func clear_selection() -> void
```

### Tile Class (scripts/tile.gd - 20 lines)
```gdscript
class_name Tile
extends Resource

## Individual puzzle tile (Rectangle Jigsaw)
var tile_id: int = 0  # Unique identifier (0 to tile_count-1)
var current_position: Vector2i = Vector2i(0, 0)  # Current grid position (column, row)
var correct_position: Vector2i = Vector2i(0, 0)  # Solution position (column, row)
var texture_region: Rect2 = Rect2()  # Region of source image (x, y, width, height)

func is_correct() -> bool:
    return current_position == correct_position

func swap_positions(other_tile: Tile) -> void:
    var temp_pos = current_position
    current_position = other_tile.current_position
    other_tile.current_position = temp_pos
```

### SpiralRing Class (scripts/spiral_ring.gd - 84 lines)
```gdscript
class_name SpiralRing
extends Resource

## Individual ring in spiral puzzle
var ring_index: int = 0  # Ring number from center (0=innermost)
var current_angle: float = 0.0  # Current rotation in degrees
var correct_angle: float = 0.0  # Target angle (always 0.0)
var angular_velocity: float = 0.0  # Rotation speed in degrees/second
var inner_radius: float = 0.0  # Inner circle radius in pixels (expands when merging)
var outer_radius: float = 0.0  # Outer circle radius in pixels
var is_locked: bool = false  # Whether ring is locked (cannot rotate/be dragged)
var merged_ring_ids: Array[int] = []  # Rings merged into this one

## KEY IMPLEMENTATION METHODS

func is_angle_correct(threshold: float = GameConstants.SPIRAL_ROTATION_SNAP_ANGLE) -> bool:
    """Check if within 1° of correct angle"""
    var angle_diff = abs(_normalize_angle(current_angle - correct_angle))
    return angle_diff <= threshold

func can_merge_with(other_ring: SpiralRing) -> bool:
    """Check merge conditions:
    - Not both locked
    - Adjacent (indices differ by 1)
    - Angle difference ≤ 5.0° (SPIRAL_MERGE_ANGLE_THRESHOLD)
    - Velocity difference ≤ 10.0°/s (SPIRAL_MERGE_VELOCITY_THRESHOLD)
    """
    if is_locked and other_ring.is_locked:
        return false
    if abs(ring_index - other_ring.ring_index) != 1:
        return false
    var angle_diff = abs(_normalize_angle(current_angle - other_ring.current_angle))
    if angle_diff > GameConstants.SPIRAL_MERGE_ANGLE_THRESHOLD:
        return false
    var velocity_diff = abs(angular_velocity - other_ring.angular_velocity)
    if velocity_diff > GameConstants.SPIRAL_MERGE_VELOCITY_THRESHOLD:
        return false
    return true

func merge_with(other_ring: SpiralRing) -> void:
    """Merge this ring with another (this ring absorbs other):
    - Average angles and velocities
    - Expand inner_radius to min of both (encompass other ring)
    - Inherit locked state if merging with locked ring
    - Track merged ring IDs
    """
    current_angle = (_normalize_angle(current_angle) + _normalize_angle(other_ring.current_angle)) / 2.0
    angular_velocity = (angular_velocity + other_ring.angular_velocity) / 2.0
    inner_radius = min(inner_radius, other_ring.inner_radius)
    if other_ring.is_locked:
        is_locked = true
        angular_velocity = 0.0
    merged_ring_ids.append(other_ring.ring_index)
    for id in other_ring.merged_ring_ids:
        if id not in merged_ring_ids:
            merged_ring_ids.append(id)

func gain_velocity(velocity: float) -> void:
    """Apply velocity from flick gesture (clamped to max)"""
    if is_locked:
        return
    angular_velocity = clamp(velocity,
        -GameConstants.SPIRAL_MAX_ANGULAR_VELOCITY,
        GameConstants.SPIRAL_MAX_ANGULAR_VELOCITY)

func can_rotate() -> bool:
    """Returns true if ring can be rotated (not locked)"""
    return not is_locked

func update_rotation(delta: float) -> void:
    """Physics update per frame:
    - Apply angular velocity to current_angle
    - Apply deceleration (200.0°/s²)
    - Stop when below 1.0°/s
    - Normalize angle to [-180, 180]
    """
    if is_locked:
        return
    current_angle += angular_velocity * delta
    current_angle = _normalize_angle(current_angle)
    if abs(angular_velocity) > GameConstants.SPIRAL_MIN_VELOCITY_THRESHOLD:
        var deceleration = GameConstants.SPIRAL_ANGULAR_DECELERATION * delta
        if angular_velocity > 0:
            angular_velocity = max(0.0, angular_velocity - deceleration)
        else:
            angular_velocity = min(0.0, angular_velocity + deceleration)
    else:
        angular_velocity = 0.0

func _normalize_angle(angle: float) -> float:
    """Convert to [-180, 180] range"""
    while angle > 180.0:
        angle -= 360.0
    while angle < -180.0:
        angle += 360.0
    return angle
```

### Arrow Class (scripts/arrow.gd - 69 lines)
```gdscript
class_name Arrow
extends Resource

enum Direction { UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3 }

## Individual arrow element (Arrow Puzzle)
var arrow_id: int = 0  # Unique identifier
var grid_position: Vector2i = Vector2i(0, 0)  # Position in grid (column, row)
var direction: Direction = Direction.UP  # Which way arrow points
var has_exited: bool = false  # Whether arrow has left the grid
var is_animating: bool = false  # Prevents double-tapping during animation

func get_rotation_degrees() -> float:
    """Returns rotation angle for rendering (0/90/180/270)"""
    match direction:
        Direction.UP: return 0.0
        Direction.RIGHT: return 90.0
        Direction.DOWN: return 180.0
        Direction.LEFT: return 270.0
        _: return 0.0

func get_direction_vector() -> Vector2i:
    """Returns movement vector for this direction"""
    match direction:
        Direction.UP: return Vector2i(0, -1)
        Direction.DOWN: return Vector2i(0, 1)
        Direction.LEFT: return Vector2i(-1, 0)
        Direction.RIGHT: return Vector2i(1, 0)
        _: return Vector2i(0, 0)

func blocks_position(check_pos: Vector2i) -> bool:
    """Check if this arrow blocks a given grid position"""
    return not has_exited and grid_position == check_pos
```

### ArrowPuzzleState Class (scripts/arrow_puzzle_state.gd - 146 lines)
```gdscript
class_name ArrowPuzzleState
extends Resource

const Arrow = preload("res://scripts/arrow.gd")

## Current arrow puzzle state
var level_id: int = 0
var difficulty: String = "easy"
var grid_size: Vector2i = Vector2i(5, 4)  # (columns, rows)
var arrows: Array[Arrow] = []  # All arrow objects
var active_arrow_count: int = 0  # Arrows still in play (not exited)
var tap_count: int = 0  # Number of taps made
var direction_set: Array[int] = []  # Two allowed directions (e.g., [LEFT, UP])
var is_solved: bool = false

## KEY IMPLEMENTATION: Arrow puzzle validation
func is_puzzle_solved() -> bool:
    """Puzzle solved when all arrows have exited"""
    return active_arrow_count == 0

func attempt_arrow_movement(arrow_id: int) -> Dictionary:
    """Core movement logic with collision detection
    Returns: {success: bool, blocked_by: int or -1}"""
    var arrow = get_arrow_by_id(arrow_id)
    if arrow == null or arrow.has_exited or arrow.is_animating:
        return {success: false, blocked_by: -1}

    var dir_vector = arrow.get_direction_vector()
    var current_pos = arrow.grid_position

    # Trace path step-by-step
    while true:
        var next_pos = current_pos + dir_vector

        # Check if out of bounds (success - arrow exits)
        if is_position_out_of_bounds(next_pos):
            return {success: true, blocked_by: -1}

        # Check if blocked by another arrow
        if is_position_blocked(next_pos, arrow_id):
            var blocking_arrow = get_arrow_at_position(next_pos)
            return {success: false, blocked_by: blocking_arrow.arrow_id if blocking_arrow else -1}

        current_pos = next_pos

func mark_arrow_exited(arrow_id: int) -> void:
    """Mark arrow as exited and decrement counter"""
    var arrow = get_arrow_by_id(arrow_id)
    if arrow != null and not arrow.has_exited:
        arrow.has_exited = true
        active_arrow_count -= 1

func get_arrow_at_position(pos: Vector2i) -> Arrow:
    """Find arrow at specific grid position"""
    for arrow in arrows:
        if arrow != null and not arrow.has_exited and arrow.grid_position == pos:
            return arrow
    return null

func is_position_blocked(pos: Vector2i, excluding_id: int) -> bool:
    """Check if position occupied by another arrow"""
    for arrow in arrows:
        if arrow != null and arrow.arrow_id != excluding_id:
            if arrow.blocks_position(pos):
                return true
    return false

func is_position_out_of_bounds(pos: Vector2i) -> bool:
    """Check if position outside grid boundaries"""
    return pos.x < 0 or pos.x >= grid_size.x or pos.y < 0 or pos.y >= grid_size.y
```

### SpiralPuzzleState Class (scripts/spiral_puzzle_state.gd - 121 lines)
```gdscript
class_name SpiralPuzzleState
extends Resource

const SpiralRing = preload("res://scripts/spiral_ring.gd")

## Current spiral puzzle state
var level_id: int = 0
var difficulty: String = "easy"
var ring_count: int = 3  # Total rings (3-7)
var rings: Array[SpiralRing] = []  # All ring objects
var active_ring_count: int = 0  # Number of unmerged rings
var rotation_count: int = 0  # Total rotations made
var hints_used: int = 0  # Hints consumed
var is_solved: bool = false
var puzzle_radius: float = 450.0  # Max radius (450.0 pixels)

## KEY IMPLEMENTATION: Spiral puzzle validation
func is_puzzle_solved() -> bool:
    """Puzzle solved when ≤1 active ring remains (only locked outermost)"""
    return active_ring_count <= 1

func update_physics(delta: float) -> void:
    """Update all rings' rotations each frame"""
    for ring in rings:
        if ring != null and not ring.is_locked:
            ring.update_rotation(delta)

func check_and_merge_rings() -> bool:
    """Detect and perform ring merges
    CRITICAL: Keeps outer ring, removes inner ring from array
    Returns true if any merge occurred"""
    var any_merged = false

    # Check adjacent rings for merge conditions
    for i in range(rings.size() - 1):
        var inner_ring = rings[i]
        var outer_ring = rings[i + 1]

        if inner_ring == null or outer_ring == null:
            continue

        if inner_ring.can_merge_with(outer_ring):
            # Keep outer ring (i+1), expand it inward to encompass inner ring
            outer_ring.inner_radius = inner_ring.inner_radius

            # Merge: average angles/velocities, inherit lock state
            outer_ring.merge_with(inner_ring)

            # Remove inner ring from array
            rings.remove_at(i)
            active_ring_count -= 1
            any_merged = true

            # Play merge sound (handled in gameplay_screen)
            if AudioManager:
                AudioManager.play_sfx("ring_merge")

            # Break and let next frame check again (indices shifted)
            break

    return any_merged

func get_ring_at_position(touch_pos: Vector2, center: Vector2) -> int:
    """Hit detection for rings - returns ring index or -1"""
    var offset = touch_pos - center
    var distance = offset.length()

    # Find ring based on radial distance (prioritize innermost)
    for i in range(rings.size()):
        var ring = rings[i]
        if ring != null and not ring.is_locked:
            if distance >= ring.inner_radius and distance <= ring.outer_radius:
                return i
    return -1

func set_ring_velocity(ring_index: int, velocity: float) -> void:
    """Apply flick momentum to ring"""
    var ring = get_ring_by_index(ring_index)
    if ring != null:
        ring.gain_velocity(velocity)
        if not ring.is_locked:
            rotation_count += 1

func rotate_ring(ring_index: int, angle_delta: float) -> void:
    """Direct drag rotation"""
    var ring = get_ring_by_index(ring_index)
    if ring != null and ring.can_rotate():
        ring.current_angle += angle_delta
        ring.current_angle = ring._normalize_angle(ring.current_angle)
        rotation_count += 1

func use_hint() -> int:
    """Snap random incorrect ring to correct angle (0°)
    Returns ring index or -1 if no rings need hint"""
    var incorrect_rings = []

    # Find all rings that are not locked and not at correct angle
    for i in range(rings.size()):
        var ring = rings[i]
        if ring != null and not ring.is_locked and not ring.is_angle_correct():
            incorrect_rings.append(i)

    if incorrect_rings.is_empty():
        return -1

    # Pick random incorrect ring
    var ring_index = incorrect_rings[randi() % incorrect_rings.size()]
    var ring = rings[ring_index]

    # Snap to correct angle
    ring.current_angle = ring.correct_angle
    ring.angular_velocity = 0.0
    hints_used += 1

    return ring_index

func get_ring_by_index(index: int) -> SpiralRing:
    """Get ring at specific index"""
    if index >= 0 and index < rings.size():
        return rings[index]
    return null

func get_correct_ring_count() -> int:
    """Count rings at correct angles"""
    var count = 0
    for ring in rings:
        if ring != null and ring.is_angle_correct():
            count += 1
    return count
```

### SpiralRingNode Visual Component (scripts/spiral_ring_node.gd - 296 lines)
**Note**: Visual rendering implementation, not a data class.

- **Base class**: `MeshInstance2D` (optimized mesh-based rendering)
- **Mesh generation**: Pre-generates ArrayMesh once in `_ready()` via `_create_ring_mesh()`
  - 128 segments, 256 vertices, 256 triangles per ring
  - UV coordinates baked into mesh (no per-frame recalculation)
- **Rotation**: Applied via node transform (`rotation = deg_to_rad(ring_data.current_angle)`)
- **Borders**: Line2D child nodes (white for unlocked, dark gray for locked)
- **Input handling**: External methods called by centralized handler in `gameplay_screen.gd`
  - `start_drag_external(touch_pos)`, `update_drag_external(touch_pos)`, `end_drag_external()`
- **Mesh regeneration**: `regenerate_mesh()` called after ring merges (when inner_radius changes)
- **Performance**: Single draw call per ring (3-7 total vs 768-1,792 in triangle-based approach)

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

## Puzzle mechanics - Arrow Puzzle
const ARROW_BOUNCE_DURATION = 0.2  # Bounce-back animation
const ARROW_EXIT_DURATION = 0.15   # Exit fade duration
const ARROW_GRID_SPACING = 10      # Pixels between arrows

## Arrow grid sizes per difficulty
const ARROW_GRID_EASY = Vector2i(5, 4)    # 20 arrows
const ARROW_GRID_NORMAL = Vector2i(6, 5)  # 30 arrows
const ARROW_GRID_HARD = Vector2i(8, 7)    # 56 arrows

const ARROW_TEXTURE_PATH = "res://assets/ui/up_arrow.png"

## Audio settings
const DEFAULT_MUSIC_VOLUME = 0.7
const DEFAULT_SOUND_VOLUME = 0.8

## Level image specifications
const LEVEL_IMAGE_SIZE = 2048  # 2048×2048 pixels
const THUMBNAIL_SIZE = 512  # 512×512 pixels

## Enums
enum Difficulty { EASY, NORMAL, HARD }
enum PuzzleType { RECTANGLE_JIGSAW, SPIRAL_TWIST, ARROW_PUZZLE }

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
