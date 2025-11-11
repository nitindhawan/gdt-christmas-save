# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Save the Christmas** is a 2D mobile puzzle game built with Godot 4.5.1. Players unscramble Christmas-themed images by rearranging jumbled rectangular tiles. The game features 20 levels with three difficulty modes (Easy, Normal, Hard), earning up to 3 stars per level.

**Platform**: Mobile (iOS/Android) - Portrait mode only
**Status**: Planning complete, implementation not yet started

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
- Properties: level_id, image_path, difficulty_configs {easy, normal, hard}
- Each difficulty specifies grid: {rows, columns, tile_count}

**PuzzleState** (`scripts/puzzle_state.gd`): Runtime puzzle state
- Tracks current tile arrangement, selected tiles, swap count
- Method: `is_puzzle_solved()` validates all tiles in correct positions

**Tile** (`scripts/tile.gd`): Individual tile data
- Properties: current_position, correct_position, texture_region
- Method: `is_correct()` compares positions

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

### Rectangle Jigsaw Puzzle Type
- Image divided into rectangular grid (MVP only supports this type)
- **Easy**: 2×3 grid (6 tiles)
- **Normal**: 3×4 grid (12 tiles)
- **Hard**: 5×6 grid (30 tiles)

### Tile Interaction
1. **First tap**: Select tile (highlight with gold border)
2. **Second tap**: Swap with first tile (0.3s tween animation)
3. **Validation**: After each swap, check if puzzle solved

### Hint System
- Automatically swaps one incorrect tile to correct position
- Limited to 3 hints per level (configurable in levels.json)
- Animation: Sparkle/glow effect on hinted tile

## Data Schema

### levels.json Structure
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
        "easy": {"rows": 2, "columns": 3, "tile_count": 6},
        "normal": {"rows": 3, "columns": 4, "tile_count": 12},
        "hard": {"rows": 5, "columns": 6, "tile_count": 30}
      },
      "hint_limit": 3
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

### Tile Generation
- Use AtlasTexture to split source image into tile regions
- Tiles must track both current_position and correct_position
- Scramble using Fisher-Yates shuffle (ensures solvability)

### Animation Standards
- **Tile swap**: 0.3s ease-in-out tween
- **Selection**: 0.1s scale to 1.05×
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


