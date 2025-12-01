# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Save the Christmas** is a 2D mobile puzzle game built with Godot 4.5.1. Players solve Christmas-themed image puzzles using three distinct mechanics: Spiral Twist (rotating rings), Rectangle Jigsaw (tile swapping), and Arrow Puzzle (directional movement). The game features 20 levels with three difficulty modes (Easy, Normal, Hard), earning up to 3 stars per level.

**Platform**: Mobile (iOS/Android) - Portrait mode only
**Status**: Implementation in progress (Spiral Puzzle feature branch active)

## Development Commands

### Running Godot Editor
```bash
"C:\dev\godot\Godot.exe"
```

### Script Validation
Always validate GDScript files after creation or modification:
```bash
"C:\dev\godot\Godot.exe" --headless --check-only --script path/to/script.gd
```

### Running the Game
Open project in Godot editor and press F5, or:
```bash
"C:\dev\godot\Godot.exe" --path save-the-christmas
```

## Project Structure

```
save-the-christmas/          # Godot project root
  ├── scenes/                # Scene files (.tscn)
  ├── scripts/               # GDScript files (.gd)
  ├── assets/
  │   ├── levels/            # Level images (2048×2048 PNG)
  │   ├── levels/thumbnails/ # Thumbnails (512×512 PNG)
  │   ├── ui/                # UI sprites and assets
  │   └── audio/             # Music and SFX (OGG format)
  └── data/
      └── levels.json        # Level definitions
```
## Development Workflow

### Scene Setup
1. Create .tscn scene files directly in `save-the-christmas/scenes/`
2. Follow proper Godot scene format (text-based .tscn)
3. Use snake_case for scene file names (e.g., `level_selection.tscn`)
4. Scene root nodes use PascalCase (e.g., `LevelSelection`)

### Script Generation
1. Generate .gd files in `save-the-christmas/scripts/`
2. Follow snake_case naming for script files (e.g., `level_manager.gd`)
3. Use class_name for reusable classes (PascalCase, e.g., `LevelData`)
4. Add proper documentation comments

### Asset Integration
1. Level images: 2048×2048 PNG in `assets/levels/`
2. Thumbnails: 512×512 PNG in `assets/levels/thumbnails/`
3. UI sprites: PNG with transparency in `assets/ui/`
4. Audio: OGG format in `assets/audio/`

## Naming Conventions (Godot 4 Standards)

### Files and Folders
- **snake_case** for all files and folders
- Examples: `level_selection.tscn`, `progress_manager.gd`, `assets/levels/`

### Scene Names vs Scene File Names
- **Scene File Names**: `snake_case` (e.g., `gameplay_screen.tscn`)
- **Scene Root Node Names**: `PascalCase` (e.g., `GameplayScreen`)
- Note: Scenes are nodes, so root follows node naming (PascalCase) while file follows file naming (snake_case)

### Class Names
- **PascalCase** for class names (defined with class_name)
- Examples: `LevelData`, `ProgressManager`, `PuzzleState`

### Node Names in Scene Tree
- **PascalCase** for all node names
- Examples: `TileContainer`, `HintButton`, `SettingsPopup`

### Variables and Functions
- **snake_case** for all variables and functions
- Examples: `current_level`, `is_level_unlocked()`, `swap_tiles()`

### Constants
- **CONSTANT_CASE** (all uppercase with underscores)
- Examples: `MAX_LEVELS`, `TILE_SWAP_DURATION`, `EASY_GRID_SIZE`

### Signals
- **snake_case** with past tense or action verbs
- Examples: `level_completed`, `tile_swapped`, `settings_changed`

### Enums
- **PascalCase** for enum names, **CONSTANT_CASE** for members
- Example: `enum Difficulty { EASY, NORMAL, HARD }`

## Architecture Overview

### AutoLoad Singletons (5 Core Systems)
These must be configured in Project Settings → AutoLoad:

1. **GameConstants** (`scripts/game_constants.gd`)
   - File paths, difficulty configs, enums
   - Constants: TOTAL_LEVELS=20, tile dimensions, animation durations

2. **GameManager** (`scripts/game_manager.gd`)
   - Scene navigation and transitions
   - Current level/difficulty state tracking

3. **ProgressManager** (`scripts/progress_manager.gd`)
   - Save/load system using ConfigFile (user://save_data.cfg)
   - Star tracking, level unlock logic
   - Functions: `is_level_unlocked()`, `is_difficulty_unlocked()`, `set_star()`

4. **LevelManager** (`scripts/level_manager.gd`)
   - Loads and parses data/levels.json
   - Manages level images and thumbnails
   - Caches loaded textures for performance

5. **AudioManager** (`scripts/audio_manager.gd`)
   - Background music and SFX playback
   - Settings persistence (music/sound/vibrations toggles)

### Core Data Classes

**LevelData** (`scripts/level_data.gd`): Level definition from levels.json
- Properties: level_id, image_path, puzzle_type, difficulty_configs {easy, normal, hard}
- Rectangle Jigsaw difficulty: {rows, columns, tile_count}
- Spiral Twist difficulty: {ring_count}
- Arrow Puzzle difficulty: {grid_size}

**PuzzleState** (`scripts/puzzle_state.gd`): Runtime rectangle jigsaw puzzle state
- Tracks current tile arrangement, selected tiles, swap count
- Method: `is_puzzle_solved()` validates all tiles in correct positions

**SpiralPuzzleState** (`scripts/spiral_puzzle_state.gd`): Runtime spiral puzzle state
- Tracks rings, active_ring_count, rotation_count, hints_used
- Method: `is_puzzle_solved()` returns true when active_ring_count == 0
- Method: `update_physics(delta)` updates all ring rotations each frame
- Method: `check_and_merge_rings()` detects and performs merges

**Tile** (`scripts/tile.gd`): Individual tile data (Rectangle Jigsaw)
- Properties: current_position, correct_position, texture_region
- Method: `is_correct()` compares positions

**Arrow** (`scripts/arrow.gd`): Individual arrow data (Arrow Puzzle)
- Properties: arrow_id, grid_position, direction, has_exited, is_animating
- Direction enum: UP, DOWN, LEFT, RIGHT
- Methods: `get_rotation_degrees()`, `get_direction_vector()`, `blocks_position()`

**ArrowPuzzleState** (`scripts/arrow_puzzle_state.gd`): Runtime arrow puzzle state
- Tracks arrows, active_arrow_count, tap_count, direction_set
- Method: `is_puzzle_solved()` returns active_arrow_count == 0
- Method: `attempt_arrow_movement()` handles collision detection and movement

**SpiralRing** (`scripts/spiral_ring.gd`): Individual ring data (Spiral Twist)
- Properties: ring_index, current_angle, angular_velocity, inner_radius, outer_radius, is_locked
- Method: `is_angle_correct()` checks if within 1° of correct angle
- Method: `can_merge_with()` validates merge conditions
- Method: `merge_with()` absorbs other ring (expands inner_radius, inherits lock state)
- Method: `gain_velocity()` applies flick velocity (checks is_locked)
- Method: `can_rotate()` returns !is_locked
- Method: `update_rotation(delta)` applies physics (velocity, deceleration)

### Scene Flow

```
LoadingScreen (initial boot)
  ├─> GameplayScreen (if level == 1)
  └─> LevelSelection (if level > 1)
      ├─> DifficultySelection (for beaten levels)
      │   └─> GameplayScreen (selected difficulty)
      └─> GameplayScreen (Easy mode for new levels)
          └─> LevelCompleteScreen
              ├─> GameplayScreen (next level)
              └─> LevelSelection (if last level)
```

### Progression Rules

- Level 1 starts unlocked on Easy
- Complete Easy of Level N → Unlocks Level N+1 Easy + Level N Normal
- Complete Normal → Unlocks Level N Hard
- Stars: Easy=1⭐, Normal=2⭐⭐, Hard=3⭐⭐⭐

## Godot 4 Naming Conventions

**Critical**: Follow these strictly as they're Godot best practices:

- **Files/Folders**: `snake_case` (e.g., `level_selection.tscn`, `game_manager.gd`)
- **Scene Root Nodes**: `PascalCase` (e.g., `LevelSelection`, `GameplayScreen`)
- **Class Names**: `PascalCase` with `class_name` keyword (e.g., `class_name LevelData`)
- **Variables/Functions**: `snake_case` (e.g., `current_level`, `get_tile_count()`)
- **Constants**: `CONSTANT_CASE` (e.g., `MAX_SPEED`, `TOTAL_LEVELS`)
- **Signals**: `snake_case`, past tense (e.g., `level_completed`, `tile_swapped`)
- **Enums**: Enum names `PascalCase`, members `CONSTANT_CASE`
  ```gdscript
  enum Difficulty { EASY, NORMAL, HARD }
  ```

## Godot 4.4.1 API Constraints

**AVOID** these unsupported features (will cause errors):

- ❌ **Type aliases**: `typedef` does NOT exist in GDScript
  ```gdscript
  # BROKEN - Don't use
  typedef RingColor = GameConstants.RingColor

  # CORRECT - Use full paths
  var color: int = GameConstants.RingColor.RED
  ```

**VERIFIED** working APIs:
- ✅ Enums with explicit values
- ✅ Global enum access from AutoLoad singletons
- ✅ Enum type annotations in function parameters

## Puzzle Mechanics

The game features THREE puzzle types that rotate through levels:
- **Level % 3 == 1 (1, 4, 7, 10, ...)**: Spiral Twist
- **Level % 3 == 2 (2, 5, 8, 11, ...)**: Rectangle Jigsaw
- **Level % 3 == 0 (3, 6, 9, 12, ...)**: Arrow Puzzle

### Spiral Twist Puzzle Type
- Circular image divided into concentric rings
- **Easy**: 3 rings
- **Normal**: 5 rings
- **Hard**: 7 rings
- **Outermost ring is static** (doesn't rotate, serves as reference frame)
- Inner rings rotate via drag or flick with momentum
- Physics-based: angular velocity (max 720°/s), deceleration (200°/s²)
- Rings merge when aligned (angle ≤5°, velocity ≤10°/s)
- **Merged rings continue rotating** until they merge with the outermost ring
- Win condition: All rings merged into the outermost ring (active_ring_count == 0)

### Rectangle Jigsaw Puzzle Type
- Image divided into rectangular grid
- **Easy**: 2×3 grid (6 tiles)
- **Normal**: 3×4 grid (12 tiles)
- **Hard**: 5×6 grid (30 tiles)

### Arrow Puzzle Type
- Grid of arrows overlaid on background image
- **Easy**: 5×4 grid (20 arrows)
- **Normal**: 6×5 grid (30 arrows)
- **Hard**: 8×7 grid (56 arrows)
- Tap arrow → moves in direction until exiting grid or hitting another arrow
- Blocked arrows bounce back with 0.2s animation
- Win condition: All arrows have exited (active_arrow_count == 0)
- Direction algorithm: 2-direction sets (LEFT+UP, LEFT+DOWN, RIGHT+UP, RIGHT+DOWN) guarantee solvability

### Ring Interaction (Spiral Twist)
1. **Touch down**: Select ring (within inner/outer radius)
2. **Drag**: Ring rotates following finger, no momentum during drag
3. **Release**:
   - Fast release → Flick detected, apply angular velocity
   - Slow release → Ring stops immediately
4. **Physics Loop**: Each frame (_process):
   - Update all ring rotations (apply velocity, deceleration)
   - Check for ring merges (adjacent rings with aligned angle/velocity)
   - Update visuals
5. **Validation**: After merge, check if puzzle solved

### Tile Interaction (Rectangle Jigsaw)
1. **First tap**: Select tile (highlight with gold border)
2. **Second tap**: Swap with first tile (0.3s tween animation)
3. **Validation**: After each swap, check if puzzle solved

### Hint System
- **Removed**: The hint system has been removed from the entire game
- All levels have hint_limit set to 0
- No hint buttons appear in gameplay screens

## Data Schema

### levels.json Structure
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
        "easy": {"ring_count": 3},
        "normal": {"ring_count": 5},
        "hard": {"ring_count": 7}
      },
      "hint_limit": 0
    },
    {
      "level_id": 2,
      "name": "Cozy Fireplace",
      "image_path": "res://assets/levels/level_02.png",
      "thumbnail_path": "res://assets/levels/thumbnails/level_02_thumb.png",
      "puzzle_type": "rectangle_jigsaw",
      "difficulty_configs": {
        "easy": {"rows": 2, "columns": 3, "tile_count": 6},
        "normal": {"rows": 3, "columns": 4, "tile_count": 12},
        "hard": {"rows": 5, "columns": 6, "tile_count": 30}
      },
      "hint_limit": 0
    },
    {
      "level_id": 3,
      "name": "Snowy Village",
      "image_path": "res://assets/levels/level_03.png",
      "thumbnail_path": "res://assets/levels/thumbnails/level_03_thumb.png",
      "puzzle_type": "arrow_puzzle",
      "difficulty_configs": {
        "easy": {"grid_size": {"x": 5, "y": 4}},
        "normal": {"grid_size": {"x": 6, "y": 5}},
        "hard": {"grid_size": {"x": 8, "y": 7}}
      },
      "hint_limit": 0
    }
  ]
}
```

### Save Data (user://save_data.cfg)
```ini
[progress]
current_level = 5
highest_level_unlocked = 5

[stars]
level_1_easy = true
level_1_normal = true
level_1_hard = false

[settings]
sound_enabled = true
music_enabled = true
vibrations_enabled = true
```

## UI Specifications

### Resolution & Layout
- **Base Resolution**: 1080×1920 (9:16 portrait)
- **Viewport Mode**: canvas_items stretch with aspect expand
- **Safe Areas**: 40px top/bottom margins for notches

### Key Measurements
- **Level Cell**: 460×560px (in 2-column grid)
- **Puzzle Area**: Varies by difficulty, max 900px width
- **Buttons**: Minimum touch target 88×88px
- **Tile Border**: 2px white (normal), 8px gold (selected)

## Testing Workflow

### Validation Checklist
1. Run script validation on all new/modified .gd files. Use `C:\dev\godot\Godot.exe --headless --check-only --script <script_file>`
   - Run from within `save-the-christmas/` directory only
   - Example: `"C:\dev\godot\Godot.exe" --headless --check-only --script scripts/level_manager.gd`
2. Test scene in isolation before integrating
3. Verify AutoLoad singletons load without errors
4. Check save data persistence (close and reopen)
5. Test on target resolution (1080×1920)

## Development Guidelines

### When Implementing Features
1. **Check Documentation First**: Reference ARCHITECTURE-MASTER.md, GAME-RULES.md, SCREEN-REQUIREMENTS.md
2. **Follow Data Schema**: Use structures defined in DATA-SCHEMA.md
3. **Update MILESTONES-AND-TASKS.md**: Mark tasks as completed when done
4. **Ask for Testing**: Cannot run Godot in this environment, request user testing

### Common Pitfalls to Avoid
- ❌ Using Godot 4.3+ APIs not available in 4.5.1
- ❌ Hardcoding values that should be in GameConstants
- ❌ Forgetting to add AutoLoad singletons to project settings
- ❌ Not respecting mobile safe areas (notches, navigation bars)
- ❌ Creating mouse-only interactions instead of touch-friendly UI

### Godot 4.5.1 API Verification
If uncertain about an API:
1. Check official Godot 4.5 documentation
2. Mark with comment: `# NEEDS_VERIFICATION_4.5.1` if unsure
3. Test with script validation command before committing

## Milestone Tracking
- Track progress in MILESTONES-AND-TASKS.md
- Mark tasks as `[x]` when completed
- Update architecture docs if significant changes made
- Request user testing after completing each milestone

## Common Patterns

### Scene Navigation
```gdscript
# From any script
get_tree().change_scene_to_file("res://scenes/level_selection.tscn")

# Or via GameManager
GameManager.navigate_to_level_selection()
```

### Accessing Singletons
```gdscript
# Check if level unlocked
var unlocked = ProgressManager.is_level_unlocked(5)

# Load level data
var level = LevelManager.get_level(3)

# Play sound effect
AudioManager.play_sfx("tile_swap")
```

### Save Data Persistence
```gdscript
# Set star and save
ProgressManager.set_star(level_id, "easy", true)
ProgressManager.save_progress()

# Load on game start
ProgressManager.load_save_data()
```

## Important Implementation Notes

### Spiral Puzzle Implementation Files
**Core Scripts**:
- `spiral_ring.gd` (84 lines): Ring data, merge logic, physics update
- `spiral_puzzle_state.gd` (121 lines): Puzzle state, ring collection, validation
- `spiral_ring_node.gd` (296 lines): MeshInstance2D-based rendering, mesh generation
- `spiral_ring_node.tscn`: Scene definition for ring node (MeshInstance2D type)

**Key Integration Points**:
- `puzzle_manager.gd`: Contains `_generate_spiral_puzzle()`, `_create_rings_from_image()`
- `gameplay_screen.gd`: Contains `_setup_spiral_puzzle()`, `_spawn_spiral_rings()`, physics loop
- `game_constants.gd`: All spiral puzzle constants (merge thresholds, physics values)

### Spiral Ring Generation
- Divide puzzle radius into equal-width rings
  - `ring_width = puzzle_radius / ring_count`
  - Ring i: `inner_radius = i * ring_width`, `outer_radius = (i+1) * ring_width`
- **Outermost ring (index = ring_count-1)**: Starts with `is_locked = true` (static reference)
- All other rings scrambled to random angles (±180°, min 20° from correct)

### Spiral Ring Rendering (Mesh-Based)
- **MeshInstance2D with pre-generated ArrayMesh**
  - Mesh created once in `_ready()` via `_create_ring_mesh()`
  - 128 segments, 256 vertices, 256 triangles per ring
  - UV coordinates baked into mesh (no per-frame recalculation)
- **Rotation via node transform** (not UV manipulation)
  - `rotation = deg_to_rad(ring_data.current_angle)`
- **Borders via Line2D children**
  - White for unlocked rings, dark gray for locked
- **Performance**: 3-7 draw calls total (vs 768-1,792 in old implementation)

### Spiral Physics Loop (CRITICAL)
Must run in `GameplayScreen._process(delta)` for smooth animation:
```gdscript
func _process(delta):
    if is_spiral_puzzle:
        spiral_state.update_physics(delta)  # Update all ring rotations
        if spiral_state.check_and_merge_rings():  # Check merges each frame
            AudioManager.play_sfx("ring_merge")
            _refresh_spiral_visuals()
            # Regenerate meshes after merge (inner_radius changes)
            for ring_node in ring_nodes:
                if ring_node != null:
                    ring_node.regenerate_mesh()
        _update_spiral_ring_visuals()  # Update visual display
        if spiral_state.is_puzzle_solved():
            _check_spiral_puzzle_solved()
```

### Spiral Input Handling
- **Centralized in `gameplay_screen.gd`** via `_on_rings_container_input()`
- Determines touched ring via radial distance check
- Calls external methods on ring nodes: `start_drag_external()`, `update_drag_external()`, `end_drag_external()`
- Ring nodes track touch history (5 samples) for flick velocity calculation
- Touch samples: angle + timestamp, used to calculate average velocity on release

### Spiral Merge Detection (CRITICAL IMPLEMENTATION)
Check adjacent rings each frame in `check_and_merge_rings()`:
- Iterate through rings array
- For each pair (i, i+1), check `can_merge_with()`:
  - Not both locked
  - Angle difference ≤ 5°
  - Velocity difference ≤ 10°/s
- **On merge** (keep outer, discard inner):
  1. Expand outer ring inward: `rings[i+1].inner_radius = rings[i].inner_radius`
  2. Average angles/velocities
  3. If merging with locked ring, result is locked
  4. **Remove inner ring**: `rings.remove_at(i)`
  5. Decrease active_ring_count
- **Result**: Rings array shrinks as merging progresses
- **Win condition**: `active_ring_count == 0` (all inner rings merged into locked outermost ring)

### Rectangle Jigsaw Tile Generation
- Use AtlasTexture to split source image into tile regions
- Tiles must track both current_position and correct_position
- Scramble using Fisher-Yates shuffle (ensures solvability)

### Arrow Puzzle Implementation Files
**Core Scripts**:
- `arrow.gd` (69 lines): Arrow element data class with direction enum
- `arrow_puzzle_state.gd` (146 lines): Puzzle state, collision detection, movement logic
- `arrow_node.gd` (107 lines): Visual arrow node with tap handling and animations
- `arrow_node.tscn`: Scene definition for arrow node (Control type)

**Key Integration Points**:
- `puzzle_manager.gd`: Contains `_generate_arrow_puzzle()`, `_create_arrows_for_grid()`
- `gameplay_screen.gd`: Contains `_setup_arrow_puzzle()`, `_spawn_arrows()`, `_on_arrow_tapped()`
- `game_constants.gd`: Arrow puzzle constants (grid sizes, animation durations, texture path)

**Arrow Generation**:
- Select random direction set from 4 options: [LEFT, UP], [LEFT, DOWN], [RIGHT, UP], [RIGHT, DOWN]
- Each arrow randomly assigned one of the two allowed directions
- Grid filled with arrows at all positions

**Arrow Movement Logic**:
- Trace path step-by-step in arrow's direction
- Exit success: Path reaches grid boundary
- Exit failure: Path blocked by another arrow (bounce animation)
- Collision detection via grid position checking

### Animation Standards
- **Tile swap**: 0.3s ease-in-out tween
- **Selection**: 0.1s scale to 1.05×
- **Arrow bounce**: 0.2s bounce-back animation
- **Arrow exit**: 0.15s fade-out
- **Screen transition**: 0.3s fade with 50px slide
- **Stars pop-in**: 0.3s each with 0.2s delay between

### Mobile Considerations
- Texture compression: Use ASTC/ETC2 for mobile
- Load level images on-demand, unload previous
- Debounce rapid tapping to prevent double-actions
- Test on physical devices for accurate performance

## Reference Documentation

See project root for detailed specs:
- **ARCHITECTURE-MASTER.md**: System architecture overview (high-level)
- **GAME-RULES.md**: Gameplay mechanics, progression rules, interactions
- **SCREEN-REQUIREMENTS.md**: UI layouts and specifications (hybrid: critical exact, others ranges)
- **DATA-SCHEMA.md**: Data structures, schemas, key implementation examples
- **MILESTONES-AND-TASKS.md**: Implementation roadmap with task breakdown
- **godot4_naming_conventions.md**: Godot 4 naming conventions
- **godot4_verified_apis.md**: Supported/unsupported Godot 4.5.1 APIs
- **BRIEF.md**: Original game design document

## Notes for AI Assistant (Claude)
- Mark all tasks as completed in MILESTONES-AND-TASKS.md when finished
- Request user testing after implementing each major feature
- Cannot run Godot editor, rely on script validation command only
- If API compatibility unclear, mark with NEEDS_VERIFICATION_4.5.1 comment
- Update architecture documents if implementation differs from plan


