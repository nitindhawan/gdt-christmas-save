# Save the Christmas - Architecture Master Document

## Game Concept
Save the Christmas is a 2D mobile puzzle game where players unscramble beautiful Christmas-themed images by rearranging jumbled rectangular tiles into their correct positions. Players progress through 20 levels, earning up to 3 stars per level based on difficulty (Easy, Normal, Hard). The game features a minimalistic premium design with a festive Christmas theme.

## High-Level Scene Architecture

### Scene Structure
```
Save the Christmas Project
├── LoadingScreen (loading_screen.tscn) - Initial loading with progress indicator
├── LevelSelection (level_selection.tscn) - Grid of level thumbnails with star display
├── DifficultySelection (difficulty_selection.tscn) - Choose Easy/Normal/Hard for a level
├── GameplayScreen (gameplay_screen.tscn) - Core puzzle gameplay with tile swapping
├── LevelCompleteScreen (level_complete_screen.tscn) - Victory screen with image display
└── SettingsPopup (settings_popup.tscn) - Modal overlay for game settings
```

### AutoLoad Systems (Singletons)
- **GameManager**: Game state, current level, difficulty tracking (game_manager.gd)
- **ProgressManager**: Save/load progress, star tracking, level unlocking (progress_manager.gd)
- **LevelManager**: Level data loading from levels.json, level definitions (level_manager.gd)
- **AudioManager**: Background music, sound effects, settings persistence (audio_manager.gd)
- **PuzzleManager**: Puzzle generation, tile scrambling, validation (puzzle_manager.gd)

## Core Game Systems

### Level Management System
- **Level Data Structure**: Each level defined in levels.json with:
  - level_id: Unique identifier (1-20)
  - image_path: Path to source image asset
  - puzzle_type: "rectangle_jigsaw" for MVP (future: "spiral_twist")
  - difficulty_configs: Grid dimensions for Easy/Normal/Hard
- **Level Loading**: LevelManager loads and parses levels.json on game start
- **Level State**: ProgressManager tracks completion status and stars earned per level

### Progression System
- **Star Collection**: Each level can earn up to 3 stars (1 per difficulty)
- **Unlock Logic**:
  - Level 1 starts unlocked on Easy difficulty
  - Complete Easy difficulty of Level N → Unlock Level N+1 Easy + Level N Normal
  - Complete Normal difficulty → Unlock Level N Hard
- **Save System**: Local persistent storage using Godot's ConfigFile
  - Stars earned per level per difficulty
  - Current highest unlocked level
  - Settings preferences (audio toggles)

### Puzzle System: Rectangle Jigsaw
- **Grid System**: Image divided into rectangular tiles
  - Easy: 2x3 grid (6 tiles)
  - Normal: 3x4 grid (12 tiles)
  - Hard: 5x6 grid (30 tiles)
- **Mechanics**:
  - PuzzleManager generates tile grid from source image
  - Tiles scrambled at gameplay start using Fisher-Yates shuffle
  - Player interaction: Tap two tiles to swap their positions
  - Real-time validation: Check if puzzle is solved after each swap
- **Visual Feedback**:
  - Selected tile: Highlight border or scale animation
  - Swap animation: Smooth tween between positions
  - Completion check: Compare current grid state with solution

### Audio System
- **Background Music**: Looping Christmas ambient music (toggleable)
- **Sound Effects**:
  - Tile select sound
  - Tile swap sound
  - Victory jingle on level complete
  - UI button clicks
- **Haptic Feedback**: Vibration on tile interactions (toggleable)
- **Persistence**: Settings saved to config file via AudioManager

## UI Implementation (Portrait Mobile)

### Resolution & Layout
- **Target Resolution**: 1080x1920 portrait (16:9 aspect ratio)
- **Viewport Strategy**: canvas_items stretch mode with aspect expand
- **Safe Areas**: Account for notches and navigation bars on modern devices

### Loading Screen (loading_screen.tscn)
- **Components**:
  - Game logo/branding (centered)
  - ProgressBar showing asset loading progress
  - Background with Christmas theme
- **Flow Logic**:
  - If current_level == 1 → Navigate to GameplayScreen (Level 1, Easy)
  - If current_level > 1 → Navigate to LevelSelection

### Level Selection Screen (level_selection.tscn)
- **Layout**:
  - Title: "Save the Christmas" (top)
  - Settings button (top-right corner)
  - GridContainer: 2 columns, scrollable
  - Each cell: Level thumbnail, star display, lock/play icon
- **Level States**:
  - Locked: Greyed out, lock icon, non-interactive
  - Unlocked unbeaten: Full color, play icon overlay, clickable
  - Beaten: Full color, 1-3 stars displayed, clickable
- **Interaction**:
  - Click beaten level → DifficultySelection
  - Click unlocked unbeaten → GameplayScreen (Easy mode)
  - Settings button → Open SettingsPopup overlay

### Difficulty Selection Screen (difficulty_selection.tscn)
- **Layout**:
  - Full preview of level image (top 60%)
  - Close button (X, top-left)
  - Share button (top-right)
  - Three difficulty buttons (bottom 30%):
    - "Play Easy" (green if available)
    - "Play Normal" (green if available, grey if locked)
    - "Play Hard" (green if available, grey if locked)
- **Button States**:
  - Enabled: Green, clickable
  - Disabled: Grey, shows lock icon
- **Interaction**:
  - Click enabled difficulty → GameplayScreen with selected difficulty
  - Close button → Return to LevelSelection

### Gameplay Screen (gameplay_screen.tscn)
- **Layout**:
  - Top HUD (10%):
    - Back button (left)
    - Level number display (center)
    - Settings button (right)
    - Share button (right)
  - Puzzle Area (80%):
    - CenterContainer with GridContainer for tiles
    - Dynamic sizing based on difficulty grid
  - Hint Button (bottom 10%): "Hint" button centered
- **Tile System**:
  - Each tile: TextureRect with portion of source image
  - Tile selection: Border highlight or scale effect
  - Swap mechanism: Two-tap selection (tap tile 1, tap tile 2, swap)
- **HUD Buttons**:
  - Back: Confirmation dialog → Return to LevelSelection
  - Share: Native share dialog with current puzzle state screenshot
  - Settings: Open SettingsPopup overlay
  - Hint: Move one random tile to correct position (limited uses optional)

### Level Complete Screen (level_complete_screen.tscn)
- **Layout**:
  - "Well Done!" title (top)
  - Completed image display (center 60%)
  - Star display: Show stars earned for this difficulty (below image)
  - Buttons (bottom):
    - Download button: Save completed image to device gallery
    - Share button: Share image via native share
    - Continue button (green): Load next level or return to LevelSelection
- **Flow Logic**:
  - Save star progress to ProgressManager
  - Unlock next level/difficulty based on progression rules
  - Continue button:
    - If next level unlocked → Load next level Easy mode
    - If last level → Return to LevelSelection

### Settings Popup (settings_popup.tscn)
- **Display**: Modal overlay (semi-transparent black background)
- **Layout**:
  - Close button (X, top-right)
  - Title: "Settings" (top)
  - Toggle switches (center):
    - Sound toggle (on/off)
    - Music toggle (on/off)
    - Vibrations toggle (on/off)
  - Buttons (bottom):
    - "Send Feedback" button (opens email/feedback form)
    - "Remove Ads" button (IAP trigger)
  - Links (bottom):
    - Privacy Policy (clickable text)
    - Terms & Conditions (clickable text)
- **Behavior**:
  - Settings changes immediately applied
  - Settings saved to ConfigFile on close
  - Close button or outside tap → Close popup

## Technical Architecture

### Core Data Structures
```gdscript
# Level definition in levels.json
{
  "level_id": 1,
  "image_path": "res://assets/levels/level_01.png",
  "puzzle_type": "rectangle_jigsaw",
  "difficulty_configs": {
    "easy": {"rows": 2, "columns": 3},
    "normal": {"rows": 3, "columns": 4},
    "hard": {"rows": 5, "columns": 6}
  }
}

# Progress save data in user://save_data.cfg
[progress]
current_level = 1
levels_completed = [1, 2, 3]

[stars]
level_1_easy = true
level_1_normal = true
level_1_hard = false

[settings]
sound_enabled = true
music_enabled = true
vibrations_enabled = true
```

### Puzzle Tile Data
```gdscript
# Tile class in PuzzleManager
class Tile:
    var tile_id: int  # Unique identifier
    var current_position: Vector2i  # Current grid position (row, col)
    var correct_position: Vector2i  # Solution position
    var texture_region: Rect2  # Portion of source image

    func is_correct() -> bool:
        return current_position == correct_position
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

## Asset Requirements

### Images
- **Level Images**: 20 high-quality Christmas-themed images
  - Resolution: 2048x2048 recommended for quality at all difficulties
  - Format: PNG with transparency support
  - Naming: level_01.png through level_20.png
- **UI Assets**:
  - Button sprites (play, settings, close, share, etc.)
  - Lock icon, star icons (empty/filled)
  - Background textures/gradients
  - Logo/branding assets

### Audio
- **Music**: 1-2 looping Christmas background tracks (OGG format)
- **Sound Effects**:
  - tile_select.ogg
  - tile_swap.ogg
  - level_complete.ogg
  - button_click.ogg

### Fonts
- Premium sans-serif font for UI text
- Christmas-themed decorative font for titles (optional)

## Development Workflow

### Initial Setup
1. Create Godot 4.5.1 project with mobile preset
2. Set up project structure (scenes/, scripts/, assets/)
3. Create AutoLoad singletons (game_manager.gd, progress_manager.gd, etc.)
4. Configure mobile export settings (iOS/Android)

### Scene Development Order
1. **LoadingScreen**: Basic loading with progress bar
2. **LevelSelection**: Grid layout with dummy data
3. **GameplayScreen**: Core puzzle mechanics and tile swapping
4. **SettingsPopup**: Settings UI and persistence
5. **DifficultySelection**: Difficulty button logic
6. **LevelCompleteScreen**: Victory display and progression

### Testing Workflow
1. **Unit Testing**: Test puzzle generation and validation logic
2. **Scene Testing**: Test each scene in isolation
3. **Integration Testing**: Test full game flow with progression
4. **Mobile Testing**: Test on actual iOS/Android devices
5. **Performance**: Monitor frame rate, memory usage, load times

### Asset Integration
1. Generate placeholder images for prototyping (Python/Pillow)
2. Replace with final Christmas-themed images
3. Generate UI button sprites with consistent style
4. Integrate audio assets and test AudioManager

## Mobile Optimization

### Performance Targets
- **60 FPS** on mid-range devices (iPhone 11, Samsung A52)
- **Load times**: < 2 seconds per level
- **Memory**: < 200MB RAM usage

### Optimization Strategies
- **Texture Compression**: Use ASTC/ETC2 compression for mobile
- **Atlas Packing**: Combine UI sprites into texture atlases
- **Level Streaming**: Load level images on-demand, unload previous
- **Tile Pooling**: Reuse tile TextureRect nodes instead of recreating

### Input Handling
- **Touch-First Design**: All interactions optimized for touch
- **Touch Targets**: Minimum 44x44 points (88x88 pixels @2x) for tappable elements
- **Gestures**: Simple tap interactions, avoid complex gestures
- **Haptic Feedback**: Use vibration for important interactions

## Current Implementation Status
**Status**: PLANNING PHASE - Architecture Documentation Complete
**Next Steps**:
- Create GAME-RULES.md for detailed puzzle mechanics
- Create SCREEN-REQUIREMENTS.md for pixel-perfect UI specs
- Create DATA-SCHEMA.md for levels.json structure
- Begin scene implementation starting with LoadingScreen
