# Save the Christmas - Godot 4.5.1 Mobile Game Project

## Project Overview
- **Engine**: Godot 4.5.1 (CRITICAL: Only use 4.5.1 compatible APIs)
- **Platform**: 2D Mobile Game (iOS/Android)
- **Language**: GDScript for game logic
- **Genre**: Puzzle game with Christmas theme

## Repository Structure
```
gdt-christmas-save/
├── save-the-christmas/    # Main Godot project files
│   ├── scenes/             # .tscn scene files
│   ├── scripts/            # .gd script files
│   ├── assets/             # Game assets (images, audio)
│   │   ├── levels/         # Level images (2048×2048 PNG)
│   │   ├── ui/             # UI sprites and icons
│   │   └── audio/          # Music and sound effects (OGG)
│   ├── data/               # Game data files
│   │   └── levels.json     # Level definitions
│   └── project.godot       # Godot project file
├── ref/                    # Reference materials
│   ├── wireframes/         # UI wireframes (PNG)
│   └── game-docs/          # Sample game documentation
├── BRIEF.md                # Game design document
├── ARCHITECTURE-MASTER.md  # System architecture
├── GAME-RULES.md           # Game mechanics and rules
├── SCREEN-REQUIREMENTS.md  # UI specifications
├── DATA-SCHEMA.md          # Data structures and schemas
├── CLAUDE.md               # This file - development guidelines
└── MILESTONES-AND-TASKS.md # Project milestones and task tracking
```

## Critical Constraints
- **Godot 4.5.1 ONLY** - If unsure about API compatibility, verify before implementing
- **Mobile-First Design** - All UI and interactions optimized for touch input
- **Portrait Orientation** - 1080×1920 resolution (9:16 aspect ratio), portrait locked
- **Performance Target**: 60 FPS on mid-range devices (iPhone 11, Samsung A52)

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

## AutoLoad Singletons
The following scripts should be added to Project Settings → AutoLoad:

1. **GameManager** (`scripts/game_manager.gd`)
   - Manages global game state, current level, current difficulty
   - Scene transitions and navigation

2. **ProgressManager** (`scripts/progress_manager.gd`)
   - Save/load player progress
   - Star tracking and level unlocking
   - Persistent storage (ConfigFile)

3. **LevelManager** (`scripts/level_manager.gd`)
   - Load and parse levels.json
   - Provide level data to gameplay systems
   - Level image loading and caching

4. **AudioManager** (`scripts/audio_manager.gd`)
   - Background music management
   - Sound effect playback
   - Audio settings persistence

5. **PuzzleManager** (`scripts/puzzle_manager.gd`)
   - Puzzle generation from level images
   - Tile scrambling algorithm
   - Puzzle validation and solving detection

## Key Architecture Decisions

### Scene Navigation Flow
```
LoadingScreen
    ├─> GameplayScreen (if current_level == 1)
    └─> LevelSelection (if current_level > 1)
        ├─> DifficultySelection (for beaten levels)
        │   └─> GameplayScreen
        └─> GameplayScreen (for unlocked unbeaten levels, Easy mode)
            └─> LevelCompleteScreen
                ├─> GameplayScreen (next level)
                └─> LevelSelection (if last level)
```

### Data Persistence
- Use Godot's ConfigFile for save data (`user://save_data.cfg`)
- Save on: level completion, settings change, app pause/background
- Save data includes: progress, stars, settings, statistics

### Puzzle Generation
- Slice source image into tiles based on difficulty grid
- Use AtlasTexture for tile regions
- Scramble using Fisher-Yates shuffle with solvability validation
- Validate solution by comparing tile positions

### Input Handling
- Two-tap swap mechanic (tap tile 1, tap tile 2, swap)
- Touch target minimum: 88×88 pixels (44×44 points @2x)
- Visual feedback: Selection highlight, swap animation

## Quality Standards
- All scripts must compile in Godot 4.5.1
- Mobile-optimized touch handling (no mouse-only interactions)
- Clear code comments and documentation
- **STRICT adherence to Godot 4 naming conventions above**
- Performance: 60 FPS minimum on target devices

## Testing Workflow
1. **Script Validation**: Use `C:\dev\godot\Godot.exe --headless --check-only --script <script_file>`
   - Run from within `save-the-christmas/` directory only
   - Example: `"C:\dev\godot\Godot.exe" --headless --check-only --script scripts/level_manager.gd`

2. **Scene Testing**: Open individual scenes in Godot editor, test in isolation

3. **Integration Testing**: Test full game flow from Loading to Level Complete

4. **Mobile Testing**: Export to Android APK or iOS IPA, test on actual devices

5. **Performance Testing**: Monitor FPS, memory usage, load times

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

## Asset Requirements Summary

### Level Images (20 total)
- **Full Resolution**: 2048×2048 PNG, Christmas-themed
- **Thumbnails**: 512×512 PNG
- **Naming**: `level_01.png` to `level_20.png`
- **Content**: Festive scenes (ornaments, snow, Santa, reindeer, etc.)

### UI Assets
- Button sprites (play, settings, close, share, hint)
- Icons (star, lock, back arrow, gear)
- Background textures/gradients
- Logo/branding assets

### Audio Assets
- **Music**: 1-2 looping Christmas tracks (OGG)
- **Sound Effects**: tile_select.ogg, tile_swap.ogg, level_complete.ogg, button_click.ogg, hint_used.ogg

## Script Validation Example
```bash
# From save-the-christmas/ directory
"C:\dev\godot\Godot.exe" --headless --check-only --script scripts/game_manager.gd
"C:\dev\godot\Godot.exe" --headless --check-only --script scripts/progress_manager.gd
"C:\dev\godot\Godot.exe" --headless --check-only --script scripts/level_manager.gd
```

## Mobile Export Configuration
- **Android**: Target SDK 33+, minimum SDK 21
- **iOS**: Target iOS 13+
- **Permissions**: Storage (for save data), optional photo library (for download feature)
- **Renderer**: Mobile renderer (Forward+)
- **Texture Compression**: ASTC for Android, PVRTC/ASTC for iOS

## Notes for AI Assistant (Claude)
- Mark all tasks as completed in MILESTONES-AND-TASKS.md when finished
- Request user testing after implementing each major feature
- Cannot run Godot editor, rely on script validation command only
- If API compatibility unclear, mark with NEEDS_VERIFICATION_4.5.1 comment
- Update architecture documents if implementation differs from plan

---

**Project Status**: Planning Phase Complete, Ready for Implementation

**Next Steps**: Begin Milestone 1 - Project Setup & Core Systems (see MILESTONES-AND-TASKS.md)
