# Save the Christmas - Architecture Master Document

**Related Documentation**:
- **DATA-SCHEMA.md** - Complete data structures (levels.json, save_data.cfg, class definitions)
- **GAME-RULES.md** - Detailed gameplay mechanics, progression rules, puzzle interactions
- **SCREEN-REQUIREMENTS.md** - UI layouts, visual specifications, component details
- **MILESTONES-AND-TASKS.md** - Implementation roadmap and task breakdown

---

## Game Concept
Save the Christmas is a 2D mobile puzzle game featuring THREE distinct puzzle mechanics: Spiral Twist (rotating concentric rings), Rectangle Jigsaw (tile swapping), and Arrow Puzzle (directional movement). Players progress through 100 levels, earning up to 3 stars per level based on difficulty (Easy, Normal, Hard). The game features a minimalistic premium design with a festive Christmas theme.

**Puzzle Types**: Level % 3 == 1: Spiral Twist, Level % 3 == 2: Rectangle Jigsaw, Level % 3 == 0: Arrow Puzzle
**Platform**: Mobile (iOS/Android) - Portrait mode only
**Target Resolution**: 1080×1920 (16:9 aspect ratio)
**Godot Version**: 4.5.1

---

## High-Level Scene Architecture

### Scene Structure
```
Save the Christmas Project
├── LoadingScreen - Initial loading with progress indicator
├── LevelSelection - Grid of level thumbnails with star display
├── DifficultySelection - Choose Easy/Normal/Hard for a level
├── GameplayScreen - Core puzzle gameplay with tile swapping
├── LevelCompleteScreen - Victory screen with image display
└── SettingsPopup - Modal overlay for game settings
```

### Scene Navigation Flow
```
LoadingScreen
    ├─> GameplayScreen (if level == 1)
    └─> LevelSelection (if level > 1)
        ├─> DifficultySelection (if level beaten)
        │   └─> GameplayScreen (selected difficulty)
        └─> GameplayScreen (if level unbeaten, Easy mode)
            └─> LevelCompleteScreen
                ├─> GameplayScreen (next level)
                └─> LevelSelection (if last level)
```

### AutoLoad Systems (Singletons)
These 6 core systems are configured in Project Settings → AutoLoad:

- **GameConstants** (`scripts/game_constants.gd`) - File paths, difficulty configs, enums, constants for both puzzle types
- **GameManager** (`scripts/game_manager.gd`) - Scene navigation, current level/difficulty tracking
- **ProgressManager** (`scripts/progress_manager.gd`) - Save/load system (ConfigFile), star tracking, level unlocking logic
- **LevelManager** (`scripts/level_manager.gd`) - Level data loading from levels.json, dynamic level generation, image caching
- **AudioManager** (`scripts/audio_manager.gd`) - Background music, sound effects, settings persistence
- **PuzzleManager** (`scripts/puzzle_manager.gd`) - Puzzle generation for both Rectangle Jigsaw and Spiral Twist, scrambling logic

---

## Core Game Systems

### Level Management
- **Total levels**: 100 (configured in levels.json, currently 3 defined)
- **Dynamic generation**: LevelManager auto-generates levels beyond JSON using 3 base images cycled
- Each level contains: level_id, name, image_path, thumbnail_path, puzzle_type, difficulty_configs
- Puzzle types rotate in 3-way pattern: Level % 3 == 1: Spiral Twist, Level % 3 == 2: Rectangle Jigsaw, Level % 3 == 0: Arrow Puzzle
- LevelManager caches textures for performance (get_level_texture, get_thumbnail_texture)
- See **DATA-SCHEMA.md** for complete levels.json structure
- **Implementation**: `scripts/level_manager.gd` (227 lines)

### Progression System
- Level 1 starts unlocked on Easy difficulty
- Complete Easy → Unlocks next level's Easy + current level's Normal
- Complete Normal → Unlocks current level's Hard
- Each level earns up to 3 stars (1 per difficulty)
- Save system uses Godot ConfigFile (user://save_data.cfg)
- See **GAME-RULES.md** for detailed progression rules and **DATA-SCHEMA.md** for save format

### Puzzle Systems

#### Puzzle Type 1: Spiral Twist (Odd Levels) - FULLY IMPLEMENTED
- Circular image divided into concentric rings: Easy (3), Normal (5), Hard (7)
- Outermost ring is static (locked=true reference frame), inner rings rotate
- Rings scrambled with random rotations at level start (±180°, min 20° from correct)
- Player interaction: Centralized input handler in gameplay_screen, drag to rotate, flick for momentum
- Physics-based: Angular velocity (max 720°/s), deceleration (200°/s²), update_physics() called in _process(delta)
- Ring merging: Adjacent rings merge when angle ≤5° and velocity ≤10°/s
- **Merge behavior**: Keeps outer ring, expands inner_radius, removes inner ring from array, regenerates meshes
- Merged rings continue rotating until they merge with the outermost locked ring
- Win condition: rings.size() == 1 (only locked outermost ring remains)
- No hint system (removed from entire game)
- **Rendering**: MeshInstance2D with pre-generated ArrayMesh (3-7 draw calls vs 768-1,792 in triangle-based approach)
- See **GAME-RULES.md** for complete mechanics
- **Implementation files**:
  - Core data: `spiral_ring.gd` (84 lines), `spiral_puzzle_state.gd` (121 lines)
  - Visual: `spiral_ring_node.gd` (296 lines, MeshInstance2D-based), `spiral_ring_node.tscn`
  - Generation: `puzzle_manager.gd` methods: _generate_spiral_puzzle(), _create_rings_from_image()
  - Gameplay: `gameplay_screen.gd` methods: _setup_spiral_puzzle(), _spawn_spiral_rings(), _process() physics loop

#### Puzzle Type 2: Rectangle Jigsaw (Even Levels) - FULLY IMPLEMENTED
- Image divided into rectangular grid: Easy (2×3), Normal (3×4), Hard (5×6)
- Tiles scrambled using Fisher-Yates shuffle at level start (ensures solvability)
- Player interaction: Drag-and-drop mechanic (drag tile over another to swap)
- Tiles in correct position become non-draggable (is_draggable = false)
- Real-time validation after each swap via is_puzzle_solved()
- Win condition: All tiles in correct positions
- No hint system (removed from entire game)
- See **GAME-RULES.md** for complete mechanics
- **Implementation files**:
  - Core data: `tile.gd` (20 lines), `puzzle_state.gd` (63 lines)
  - Visual: `tile_node.gd` (196 lines), `tile_node.tscn`
  - Generation: `puzzle_manager.gd` methods: _generate_rectangle_puzzle(), create_tiles_from_image(), scramble_tiles()
  - Gameplay: `gameplay_screen.gd` methods: _setup_puzzle_grid(), _spawn_tiles(), _on_tile_drag_ended()

#### Puzzle Type 3: Arrow Puzzle (Levels divisible by 3) - FULLY IMPLEMENTED
- Grid of arrows overlaid on background image: Easy (5×4=20), Normal (6×5=30), Hard (8×7=56)
- Direction algorithm: 2-direction sets (LEFT+UP, LEFT+DOWN, RIGHT+UP, RIGHT+DOWN) guarantee solvability
- Player interaction: Tap arrow to move it in its direction
- Movement: Arrow exits grid (success, disappears) or hits another arrow (bounce back with 0.2s animation)
- Real-time validation via is_puzzle_solved() when arrows exit
- Win condition: All arrows have exited the grid (active_arrow_count == 0)
- No hint system (removed from entire game)
- See **GAME-RULES.md** for complete mechanics
- **Implementation files**:
  - Core data: `arrow.gd` (69 lines), `arrow_puzzle_state.gd` (146 lines)
  - Visual: `arrow_node.gd` (107 lines), `arrow_node.tscn`
  - Generation: `puzzle_manager.gd` methods: _generate_arrow_puzzle(), _create_arrows_for_grid()
  - Gameplay: `gameplay_screen.gd` methods: _setup_arrow_puzzle(), _spawn_arrows(), _on_arrow_tapped()

### Audio System - IMPLEMENTED (placeholder audio paths)
- Background music: Looping Christmas ambient tracks (toggleable via ProgressManager)
- Sound effects: tile_pickup, tile_drop, tile_select, tile_swap, ring_merge, level_complete, button_click, error (for blocked arrow)
- Haptic feedback on tile/ring interactions (toggleable, uses Input.vibrate_handheld on mobile)
- All settings persist via ProgressManager to user://save_data.cfg
- Audio files in OGG format, stored in assets/audio/ (paths defined in AudioManager.SFX_PATHS)
- **Implementation**: `scripts/audio_manager.gd` (148 lines)
- Note: Actual audio files not yet added (placeholder paths configured)

---

## Asset Requirements Overview

### Images
- **Level Images**: Currently 3 test images (level_01.png, level_02.png, level_03.png) at 2048×2048 PNG
  - System supports 100 levels via dynamic generation cycling through base images
  - Odd-numbered levels require circular images for Spiral Twist puzzles
- **Thumbnails**: 3 test thumbnails (512×512 PNG) in assets/levels/thumbnails/
- **UI Assets**: Generated placeholders (buttons, icons, backgrounds)
- See **DATA-SCHEMA.md** for detailed naming conventions
- **Current Status**: 3 levels fully functional, 100 levels supported via dynamic generation

### Audio
- **Music**: 1-2 looping Christmas tracks (OGG)
- **Sound Effects**: tile_select.ogg, tile_swap.ogg, level_complete.ogg, button_click.ogg

### Fonts
- Premium sans-serif font for UI text
- Christmas-themed decorative font for titles (optional)

---

## Mobile Optimization

### Performance Targets
- **60 FPS** on mid-range devices (iPhone 11, Samsung A52)
- **Load times**: < 2 seconds per level
- **Memory**: < 200MB RAM usage

### Key Strategies
- Texture compression: ASTC/ETC2 for mobile
- Atlas packing for UI sprites
- On-demand level image loading with unloading
- Touch-first design with minimum 88×88px touch targets
- Safe area handling for notches and navigation bars

---

## Development Workflow

### Initial Setup
1. Create Godot 4.5.1 project with mobile preset
2. Set up folder structure: scenes/, scripts/, assets/, data/
3. Create and configure 5 AutoLoad singletons
4. Configure mobile export settings

### Scene Development Order
1. LoadingScreen → 2. LevelSelection → 3. GameplayScreen → 4. SettingsPopup → 5. DifficultySelection → 6. LevelCompleteScreen

### Testing Approach
- Unit testing for puzzle generation and validation
- Scene testing in isolation before integration
- Full game flow testing with progression
- Mobile device testing (iOS/Android)
- Performance monitoring (FPS, memory, load times)

See **MILESTONES-AND-TASKS.md** for detailed implementation tasks and timeline.

---

## Current Status
**Phase**: CORE GAMEPLAY COMPLETE - Milestones 1-5 Implemented
**Branch**: feature/spiral-puzzle (clean working tree)
**Next Milestone**: Milestone 6 - Audio & Polish

**Completed Implementation**:
- All 6 AutoLoad singletons functional (GameConstants, GameManager, ProgressManager, LevelManager, AudioManager, PuzzleManager)
- All core scenes implemented (LoadingScreen, LevelSelection, DifficultySelection, GameplayScreen, LevelCompleteScreen, SettingsPopup)
- All three puzzle types fully functional (Spiral Twist, Rectangle Jigsaw, and Arrow Puzzle)
- Complete progression system with star tracking and level unlocking
- Save/load system using ConfigFile (user://save_data.cfg)
- Dynamic level generation supporting 100+ levels from 3 base images

**Working Features**:
- Spiral Twist: Physics-based ring rotation with flick momentum and merging
- Rectangle Jigsaw: Drag-and-drop tile swapping with validation
- Arrow Puzzle: Tap-based directional movement with collision detection
- Full scene navigation flow (Loading → LevelSelection → Difficulty/Gameplay → Complete)
- Progress persistence (stars, unlocked levels, settings)
- Settings popup (music, sound, vibrations toggles)

**Remaining Work**:
- Add actual audio assets (music and SFX files)
- UI/UX polish (animations, transitions, effects)
- Performance optimization and mobile testing
- Full 20 unique level images (currently using 3 cycled)

Refer to detailed documentation for implementation specifics:
- Data structures → **DATA-SCHEMA.md**
- Game mechanics → **GAME-RULES.md**
- UI specifications → **SCREEN-REQUIREMENTS.md**
- Implementation tasks → **MILESTONES-AND-TASKS.md**
