# Save the Christmas - Architecture Master Document

**Related Documentation**:
- **DATA-SCHEMA.md** - Complete data structures (levels.json, save_data.cfg, class definitions)
- **GAME-RULES.md** - Detailed gameplay mechanics, progression rules, puzzle interactions
- **SCREEN-REQUIREMENTS.md** - UI layouts, visual specifications, component details
- **MILESTONES-AND-TASKS.md** - Implementation roadmap and task breakdown

---

## Game Concept
Save the Christmas is a 2D mobile puzzle game where players unscramble beautiful Christmas-themed images by rearranging jumbled rectangular tiles into their correct positions. Players progress through 20 levels, earning up to 3 stars per level based on difficulty (Easy, Normal, Hard). The game features a minimalistic premium design with a festive Christmas theme.

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
These 5 core systems must be configured in Project Settings → AutoLoad:

- **GameConstants** - File paths, difficulty configs, enums, constants
- **GameManager** - Scene navigation, current level/difficulty tracking
- **ProgressManager** - Save/load system, star tracking, level unlocking logic
- **LevelManager** - Level data loading from levels.json, image caching
- **AudioManager** - Background music, sound effects, settings persistence

---

## Core Game Systems

### Level Management
- 20 levels total, each defined in `data/levels.json`
- Each level contains: level_id, image_path, puzzle_type, difficulty_configs
- LevelManager loads and caches level data on game start
- See **DATA-SCHEMA.md** for complete levels.json structure

### Progression System
- Level 1 starts unlocked on Easy difficulty
- Complete Easy → Unlocks next level's Easy + current level's Normal
- Complete Normal → Unlocks current level's Hard
- Each level earns up to 3 stars (1 per difficulty)
- Save system uses Godot ConfigFile (user://save_data.cfg)
- See **GAME-RULES.md** for detailed progression rules and **DATA-SCHEMA.md** for save format

### Puzzle System: Rectangle Jigsaw (MVP)
- Image divided into rectangular grid: Easy (2×3), Normal (3×4), Hard (5×6)
- Tiles scrambled using Fisher-Yates shuffle at level start
- Player interaction: Two-tap swap mechanic (tap tile 1, tap tile 2, swap)
- Real-time validation after each swap
- Hint system: Automatically places one incorrect tile correctly
- See **GAME-RULES.md** for complete mechanics

### Audio System
- Background music: Looping Christmas ambient tracks (toggleable)
- Sound effects: Tile select, tile swap, level complete, button clicks
- Haptic feedback on tile interactions (toggleable)
- All settings persist via AudioManager to ConfigFile
- Audio files in OGG format, stored in assets/audio/

---

## Asset Requirements Overview

### Images
- **Level Images**: 20 images (2048×2048 PNG), named level_01.png to level_20.png
- **Thumbnails**: 20 thumbnails (512×512 PNG), in assets/levels/thumbnails/
- **UI Assets**: Buttons, icons (lock, star, play), backgrounds, logo
- See **DATA-SCHEMA.md** for detailed naming conventions

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
**Phase**: PLANNING COMPLETE - Ready for Implementation
**Next Milestone**: Milestone 1 - Project Setup & Core Systems

Refer to detailed documentation for implementation specifics:
- Data structures → **DATA-SCHEMA.md**
- Game mechanics → **GAME-RULES.md**
- UI specifications → **SCREEN-REQUIREMENTS.md**
- Implementation tasks → **MILESTONES-AND-TASKS.md**
