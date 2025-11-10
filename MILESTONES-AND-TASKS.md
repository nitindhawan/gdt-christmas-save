# Save the Christmas - Milestones and Tasks

## Project Status
**Current Phase**: Planning Complete
**Godot Version**: 4.5.1
**Platform**: Mobile (iOS/Android)
**Last Updated**: [Auto-update on task completion]

---

## Milestone 1: Project Setup & Core Systems
**Goal**: Set up Godot project structure and implement core AutoLoad systems
**Estimated Time**: 2-3 days
**Status**: ⏳ Not Started

### Tasks

#### 1.1 Project Initialization
- [ ] Create new Godot 4.5.1 project named "save-the-christmas"
- [ ] Configure project settings:
  - [ ] Set resolution to 1080×1920 (portrait)
  - [ ] Set stretch mode to canvas_items with aspect expand
  - [ ] Lock orientation to portrait
  - [ ] Configure mobile renderer (Forward+)
- [ ] Create folder structure:
  - [ ] `scenes/` for .tscn files
  - [ ] `scripts/` for .gd files
  - [ ] `assets/levels/` for level images
  - [ ] `assets/levels/thumbnails/` for thumbnails
  - [ ] `assets/ui/` for UI sprites
  - [ ] `assets/audio/` for sound files
  - [ ] `data/` for levels.json

#### 1.2 Core AutoLoad Systems
- [ ] Create `scripts/game_constants.gd` - Game constants and enums
  - [ ] Define Difficulty enum (EASY, NORMAL, HARD)
  - [ ] Define file paths constants
  - [ ] Define grid configurations
  - [ ] Validate with script check command
- [ ] Create `scripts/game_manager.gd` - Game state manager
  - [ ] Scene navigation functions
  - [ ] Current level/difficulty tracking
  - [ ] Scene transition logic
  - [ ] Validate with script check command
- [ ] Create `scripts/progress_manager.gd` - Save/load system
  - [ ] Save data loading from ConfigFile
  - [ ] Star tracking (get_star, set_star)
  - [ ] Level unlock logic (is_level_unlocked, is_difficulty_unlocked)
  - [ ] Save data persistence functions
  - [ ] Validate with script check command
- [ ] Create `scripts/level_manager.gd` - Level data management
  - [ ] Load and parse levels.json
  - [ ] Level data storage (array of LevelData)
  - [ ] Level image loading and caching
  - [ ] Validate with script check command
- [ ] Create `scripts/audio_manager.gd` - Audio control
  - [ ] Background music player
  - [ ] Sound effect player
  - [ ] Settings persistence (music/sound/vibrations)
  - [ ] Validate with script check command
- [ ] Configure AutoLoad in Project Settings for all 5 managers

#### 1.3 Data Classes
- [ ] Create `scripts/level_data.gd` - Level definition class
  - [ ] Properties: level_id, name, image_path, thumbnail_path, difficulty_configs
  - [ ] Methods: get_difficulty_config(), get_tile_count(), get_grid_size()
  - [ ] Validate with script check command
- [ ] Create `scripts/puzzle_state.gd` - Puzzle state class
  - [ ] Properties: level_id, difficulty, tiles, selected_tile_index, swap_count
  - [ ] Methods: is_puzzle_solved(), get_tile_at_position()
  - [ ] Validate with script check command
- [ ] Create `scripts/tile.gd` - Tile data class
  - [ ] Properties: tile_id, current_position, correct_position, texture_region
  - [ ] Methods: is_correct(), swap_positions()
  - [ ] Validate with script check command

#### 1.4 Test Data Setup
- [ ] Create `data/levels.json` with 3 test levels
- [ ] Add placeholder images (3 test images at 2048×2048)
- [ ] Add placeholder thumbnails (3 test thumbnails at 512×512)

**Milestone 1 Acceptance Criteria**:
- ✅ Project opens in Godot 4.5.1 without errors
- ✅ All 5 AutoLoad systems load successfully
- ✅ All scripts pass validation (`--headless --check-only --script`)
- ✅ Test levels.json loads without errors

---

## Milestone 2: Loading & Level Selection Screens
**Goal**: Implement first two screens (Loading, Level Selection)
**Estimated Time**: 3-4 days
**Status**: ⏳ Not Started

### Tasks

#### 2.1 Loading Screen
- [ ] Create `scenes/loading_screen.tscn`
  - [ ] Add background (ColorRect or TextureRect)
  - [ ] Add game logo (centered, 300×300px)
  - [ ] Add ProgressBar (600×40px, centered bottom)
  - [ ] Add "Loading..." label
- [ ] Create `scripts/loading_screen.gd`
  - [ ] Load levels.json via LevelManager
  - [ ] Load save data via ProgressManager
  - [ ] Simulate loading progress (or real asset loading)
  - [ ] Navigate to correct screen based on current_level
  - [ ] Validate with script check command
- [ ] Test loading screen flow

#### 2.2 Level Selection Screen
- [ ] Create `scenes/level_selection.tscn`
  - [ ] Add title label "Save the Christmas"
  - [ ] Add settings button (top-right, 80×80px)
  - [ ] Add ScrollContainer for level grid
  - [ ] Add GridContainer (2 columns)
- [ ] Create `scripts/level_selection.gd`
  - [ ] Populate grid with level cells dynamically
  - [ ] Load thumbnails from LevelManager
  - [ ] Display stars based on ProgressManager data
  - [ ] Handle level cell clicks (beaten vs unbeaten vs locked)
  - [ ] Navigate to DifficultySelection or GameplayScreen
  - [ ] Validate with script check command
- [ ] Create `scenes/level_cell.tscn` (reusable component)
  - [ ] TextureRect for thumbnail
  - [ ] Label for level number
  - [ ] Star icons (3 stars: filled/unfilled)
  - [ ] Play icon overlay (for unbeaten)
  - [ ] Lock icon overlay (for locked)
  - [ ] Border styling (green/gold/grey)
- [ ] Create `scripts/level_cell.gd`
  - [ ] Setup function (set level_id, thumbnail, stars, state)
  - [ ] Visual state updates (locked, unlocked, beaten)
  - [ ] Click handling with state validation
  - [ ] Hover/touch feedback animation
  - [ ] Validate with script check command

**Milestone 2 Acceptance Criteria**:
- ✅ Loading screen displays and navigates correctly
- ✅ Level Selection shows 3 test levels with proper states
- ✅ Clicking unlocked level navigates to next screen
- ✅ Locked levels show toast/message and don't navigate
- ✅ Settings button opens settings popup (placeholder OK)

---

## Milestone 3: Difficulty Selection & Settings
**Goal**: Implement difficulty selection and settings popup
**Estimated Time**: 2-3 days
**Status**: ⏳ Not Started

### Tasks

#### 3.1 Difficulty Selection Screen
- [ ] Create `scenes/difficulty_selection.tscn`
  - [ ] Add close button (X, top-left)
  - [ ] Add share button (top-right)
  - [ ] Add level number label
  - [ ] Add preview image (900×900px)
  - [ ] Add 3 difficulty buttons (Easy, Normal, Hard)
  - [ ] Add star indicators on each button
- [ ] Create `scripts/difficulty_selection.gd`
  - [ ] Initialize with level_id parameter
  - [ ] Load level preview from LevelManager
  - [ ] Check difficulty unlock status from ProgressManager
  - [ ] Enable/disable buttons based on unlock status
  - [ ] Handle difficulty selection → navigate to GameplayScreen
  - [ ] Handle close button → return to LevelSelection
  - [ ] Handle share button → native share (placeholder)
  - [ ] Validate with script check command

#### 3.2 Settings Popup
- [ ] Create `scenes/settings_popup.tscn`
  - [ ] Add semi-transparent overlay (full screen)
  - [ ] Add modal panel (900×1200px, centered)
  - [ ] Add close button (X)
  - [ ] Add "Settings" title
  - [ ] Add 3 toggle switches (Sound, Music, Vibrations)
  - [ ] Add "Send Feedback" button
  - [ ] Add "Remove Ads" button
  - [ ] Add Privacy and Terms links
- [ ] Create `scripts/settings_popup.gd`
  - [ ] Load current settings from AudioManager
  - [ ] Handle toggle changes (apply immediately)
  - [ ] Save settings on close via AudioManager
  - [ ] Handle close button and outside tap
  - [ ] Handle "Send Feedback" button (email or web form)
  - [ ] Handle "Remove Ads" button (IAP placeholder)
  - [ ] Handle Privacy/Terms links (open browser)
  - [ ] Validate with script check command
- [ ] Integrate settings popup with LevelSelection and GameplayScreen

**Milestone 3 Acceptance Criteria**:
- ✅ Difficulty Selection displays level preview correctly
- ✅ Buttons show proper locked/unlocked states
- ✅ Clicking unlocked difficulty navigates to GameplayScreen
- ✅ Settings popup opens from LevelSelection
- ✅ Settings changes persist after closing popup

---

## Milestone 4: Puzzle System & Gameplay
**Goal**: Implement core puzzle mechanics and gameplay screen
**Estimated Time**: 5-6 days
**Status**: ⏳ Not Started

### Tasks

#### 4.1 Puzzle Manager System
- [ ] Create `scripts/puzzle_manager.gd` (if not done in Milestone 1)
  - [ ] Function: generate_puzzle(level_data, difficulty) → PuzzleState
  - [ ] Function: create_tiles_from_image(texture, grid_size) → Array[Tile]
  - [ ] Function: scramble_tiles(puzzle_state) using Fisher-Yates
  - [ ] Function: validate_solvability(puzzle_state) → bool
  - [ ] Validate with script check command
- [ ] Add PuzzleManager to AutoLoad if not already added

#### 4.2 Tile Node Component
- [ ] Create `scenes/tile_node.tscn`
  - [ ] TextureRect for tile image
  - [ ] Selection border (hidden by default)
  - [ ] Touch area (Control node for input)
- [ ] Create `scripts/tile_node.gd`
  - [ ] Setup function (set tile data, texture region)
  - [ ] Selection visual feedback (border, scale)
  - [ ] Click/touch handling
  - [ ] Swap animation (tween position)
  - [ ] Validate with script check command

#### 4.3 Gameplay Screen
- [ ] Create `scenes/gameplay_screen.tscn`
  - [ ] Add top HUD (back, level label, share, settings)
  - [ ] Add CenterContainer for puzzle grid
  - [ ] Add GridContainer (dynamic size based on difficulty)
  - [ ] Add hint button (bottom)
- [ ] Create `scripts/gameplay_screen.gd`
  - [ ] Initialize with level_id and difficulty parameters
  - [ ] Load level data from LevelManager
  - [ ] Generate puzzle via PuzzleManager
  - [ ] Spawn tile nodes in grid
  - [ ] Handle tile selection (first tap)
  - [ ] Handle tile swap (second tap)
  - [ ] Animate tile swaps with tweens
  - [ ] Check puzzle solved after each swap
  - [ ] Navigate to LevelCompleteScreen on solve
  - [ ] Handle hint button (swap one tile to correct position)
  - [ ] Handle back button (show confirmation dialog)
  - [ ] Handle share button (screenshot + native share)
  - [ ] Handle settings button (open SettingsPopup)
  - [ ] Validate with script check command

#### 4.4 Puzzle Validation & Solving
- [ ] Implement `PuzzleState.is_puzzle_solved()` logic
- [ ] Test puzzle solving with different grid sizes
- [ ] Add visual feedback for puzzle completion (sparkle effect, etc.)

**Milestone 4 Acceptance Criteria**:
- ✅ Gameplay screen loads with scrambled tiles
- ✅ Tiles can be selected and swapped with smooth animation
- ✅ Puzzle correctly detects when solved
- ✅ Hint button swaps one tile to correct position
- ✅ All HUD buttons functional

---

## Milestone 5: Level Complete & Progression
**Goal**: Implement level completion screen and progression logic
**Estimated Time**: 3-4 days
**Status**: ⏳ Not Started

### Tasks

#### 5.1 Level Complete Screen
- [ ] Create `scenes/level_complete_screen.tscn`
  - [ ] Add "Well Done!" title
  - [ ] Add subtitle ("You have solved Level N")
  - [ ] Add star display (1-3 stars based on difficulty)
  - [ ] Add completed image display (900×900px)
  - [ ] Add share button
  - [ ] Add download button (optional)
  - [ ] Add continue button (green, 800×140px)
- [ ] Create `scripts/level_complete_screen.gd`
  - [ ] Initialize with level_id and difficulty parameters
  - [ ] Display completed image from LevelManager
  - [ ] Show appropriate stars (1, 2, or 3)
  - [ ] Animate stars appearing (sequential pop-in)
  - [ ] Save star progress via ProgressManager
  - [ ] Unlock next level/difficulty via ProgressManager
  - [ ] Handle share button (share completed image)
  - [ ] Handle download button (save to gallery, requires permissions)
  - [ ] Handle continue button:
    - If next level exists → GameplayScreen (next level, Easy)
    - If last level → LevelSelection
  - [ ] Validate with script check command

#### 5.2 Progression Logic Integration
- [ ] Implement `ProgressManager.unlock_next_level()` logic
- [ ] Test star saving and persistence
- [ ] Test level unlocking after completion
- [ ] Test difficulty unlocking (Easy → Normal → Hard)
- [ ] Verify progression rules from GAME-RULES.md

#### 5.3 Full Game Flow Testing
- [ ] Test complete flow: Loading → LevelSelection → Difficulty → Gameplay → Complete
- [ ] Test returning to LevelSelection after completion
- [ ] Test selecting beaten level shows DifficultySelection
- [ ] Test locked levels are non-interactive

**Milestone 5 Acceptance Criteria**:
- ✅ Level Complete screen displays correctly after puzzle solved
- ✅ Stars saved correctly to save data
- ✅ Next level unlocks after Easy completion
- ✅ Difficulty unlocks based on progression rules
- ✅ Continue button navigates to correct next screen
- ✅ Full game flow works end-to-end

---

## Milestone 6: Audio & Polish
**Goal**: Implement audio system and polish UI/UX
**Estimated Time**: 3-4 days
**Status**: ⏳ Not Started

### Tasks

#### 6.1 Audio Implementation
- [ ] Add background music tracks (1-2 Christmas loops)
- [ ] Add sound effects:
  - [ ] tile_select.ogg (tile selected)
  - [ ] tile_swap.ogg (tiles swapped)
  - [ ] level_complete.ogg (puzzle solved jingle)
  - [ ] button_click.ogg (UI button clicks)
  - [ ] hint_used.ogg (hint activated)
- [ ] Implement AudioManager playback functions:
  - [ ] play_music(track_name, loop=true)
  - [ ] play_sfx(sfx_name)
  - [ ] stop_music()
  - [ ] set_music_volume(volume)
  - [ ] set_sfx_volume(volume)
- [ ] Integrate audio triggers:
  - [ ] Background music on LevelSelection and GameplayScreen
  - [ ] Tile select sound on first tap
  - [ ] Tile swap sound on second tap
  - [ ] Level complete jingle on puzzle solve
  - [ ] Button click sounds on all UI buttons
  - [ ] Hint sound on hint activation
- [ ] Test audio settings (mute/unmute works correctly)

#### 6.2 Haptic Feedback
- [ ] Implement haptic vibration on tile selection
- [ ] Implement haptic vibration on tile swap
- [ ] Implement haptic feedback on level complete
- [ ] Test haptic settings toggle (enable/disable works)

#### 6.3 UI/UX Polish
- [ ] Add animations:
  - [ ] Screen transitions (fade + slide)
  - [ ] Button hover/press animations
  - [ ] Level Complete star pop-in animation
  - [ ] Tile swap animation (smooth tween)
  - [ ] Selection highlight animation
- [ ] Add visual effects:
  - [ ] Sparkle/confetti on puzzle completion (optional)
  - [ ] Glow effect on hint tile swap
  - [ ] Smooth scrolling in LevelSelection
- [ ] Improve touch feedback:
  - [ ] Visual feedback on button press
  - [ ] Touch target sizes (minimum 88×88px)
  - [ ] Debounce rapid tapping
- [ ] Test on different screen sizes (safe areas, notches)

#### 6.4 Performance Optimization
- [ ] Profile FPS on gameplay screen (target 60 FPS)
- [ ] Optimize tile texture loading (use atlases if needed)
- [ ] Test memory usage (target < 200MB)
- [ ] Optimize level image loading (load on-demand, unload previous)

**Milestone 6 Acceptance Criteria**:
- ✅ Background music plays and loops correctly
- ✅ All sound effects trigger at appropriate times
- ✅ Audio settings work (mute/unmute persists)
- ✅ Haptic feedback works on supported devices
- ✅ All animations smooth at 60 FPS
- ✅ UI feels responsive and polished

---

## Milestone 7: Content & Testing
**Goal**: Add full 20 levels and comprehensive testing
**Estimated Time**: 4-5 days
**Status**: ⏳ Not Started

### Tasks

#### 7.1 Level Content Creation
- [ ] Create or source 20 Christmas-themed images (2048×2048 PNG)
  - Images should be high-quality, festive, visually distinct
  - Examples: ornaments, snow scenes, Santa, reindeer, gifts, etc.
- [ ] Generate thumbnails for all 20 levels (512×512 PNG)
- [ ] Update `data/levels.json` with all 20 levels
  - Add proper names for each level
  - Verify all paths and configurations
- [ ] Test loading all 20 levels in game

#### 7.2 Comprehensive Testing
- [ ] Test all 20 levels on each difficulty (Easy, Normal, Hard)
- [ ] Test progression system:
  - [ ] Verify levels unlock correctly
  - [ ] Verify difficulties unlock correctly
  - [ ] Verify stars save correctly
- [ ] Test edge cases:
  - [ ] Complete Level 20 (last level)
  - [ ] Reset save data and start fresh
  - [ ] Close and reopen app (persistence)
  - [ ] Rapid button clicking (debouncing)
- [ ] Test on multiple devices:
  - [ ] Android phone (mid-range)
  - [ ] Android tablet (if supporting tablets)
  - [ ] iPhone (mid-range)
  - [ ] Test with different screen sizes and notches

#### 7.3 Bug Fixes
- [ ] Fix any bugs discovered during testing
- [ ] Verify all scripts pass validation
- [ ] Test save data corruption recovery
- [ ] Test missing asset handling (graceful fallbacks)

**Milestone 7 Acceptance Criteria**:
- ✅ All 20 levels load and play correctly
- ✅ All difficulty levels tested and working
- ✅ Progression system works flawlessly across all levels
- ✅ No critical bugs found
- ✅ Game tested on at least 2 different devices

---

## Milestone 8: Mobile Export & Release Preparation
**Goal**: Export to Android/iOS and prepare for release
**Estimated Time**: 3-4 days
**Status**: ⏳ Not Started

### Tasks

#### 8.1 Android Export
- [ ] Configure Android export settings:
  - [ ] Set package name (e.g., com.yourstudio.savethechristmas)
  - [ ] Set app name "Save the Christmas"
  - [ ] Add app icon (1024×1024 PNG)
  - [ ] Set target SDK 33+, minimum SDK 21
  - [ ] Configure permissions (storage for save data)
  - [ ] Set screen orientation to portrait
- [ ] Generate Android keystore for signing
- [ ] Export Android APK (debug build)
- [ ] Test APK on physical Android device
- [ ] Export Android App Bundle (release build)
- [ ] Test App Bundle (internal testing track)

#### 8.2 iOS Export (if applicable)
- [ ] Configure iOS export settings:
  - [ ] Set bundle identifier (e.g., com.yourstudio.savethechristmas)
  - [ ] Set app name "Save the Christmas"
  - [ ] Add app icon (1024×1024 PNG)
  - [ ] Set target iOS 13+
  - [ ] Configure permissions (photo library for download feature)
  - [ ] Set screen orientation to portrait
- [ ] Generate iOS provisioning profile
- [ ] Export iOS IPA (debug build)
- [ ] Test IPA on physical iOS device (TestFlight)
- [ ] Export iOS IPA (release build)

#### 8.3 Release Preparation
- [ ] Prepare app store assets:
  - [ ] App icon (1024×1024)
  - [ ] Screenshots (multiple devices)
  - [ ] Feature graphic (Android)
  - [ ] App description text
  - [ ] Privacy policy (if required)
  - [ ] Terms & conditions (if required)
- [ ] Create promotional materials:
  - [ ] Trailer video (optional)
  - [ ] Social media graphics
- [ ] Final QA testing on release builds
- [ ] Prepare release notes

**Milestone 8 Acceptance Criteria**:
- ✅ Android APK/App Bundle generated successfully
- ✅ iOS IPA generated successfully (if applicable)
- ✅ App tested on physical devices without crashes
- ✅ All app store assets prepared
- ✅ Release builds pass final QA

---

## Milestone 9: Post-MVP Enhancements (Optional)
**Goal**: Implement features from "Future Features" section
**Estimated Time**: Variable
**Status**: ⏳ Not Started

### Optional Features
- [ ] **Spiral Puzzle Type**: Implement circular/spiral puzzle variant
- [ ] **Daily Puzzle**: New puzzle every day with special rewards
- [ ] **Timed Mode**: Race against the clock
- [ ] **Achievement System**: Badges for milestones
- [ ] **Gallery**: View completed images in full resolution
- [ ] **Social Features**: Leaderboards, friend challenges
- [ ] **Ad Integration**: Banner ads, rewarded video for hints
- [ ] **IAP**: Hint packs, level packs, remove ads
- [ ] **Multiple Theme Packs**: Halloween, Easter, Summer themes

---

## Progress Summary

### Completed Milestones
- [x] **Milestone 0**: Planning and Documentation (COMPLETE)

### In Progress
- [ ] **Milestone 1**: Project Setup & Core Systems

### Not Started
- [ ] **Milestone 2**: Loading & Level Selection Screens
- [ ] **Milestone 3**: Difficulty Selection & Settings
- [ ] **Milestone 4**: Puzzle System & Gameplay
- [ ] **Milestone 5**: Level Complete & Progression
- [ ] **Milestone 6**: Audio & Polish
- [ ] **Milestone 7**: Content & Testing
- [ ] **Milestone 8**: Mobile Export & Release Preparation
- [ ] **Milestone 9**: Post-MVP Enhancements (Optional)

### Overall Progress
**0% Complete** (0/8 MVP milestones)

---

## Notes
- Update this file as tasks are completed (mark with [x])
- Request user testing after each milestone
- Use script validation command for all .gd files
- Refer to architecture docs when implementing features
- If blocked or uncertain, mark with "NEEDS_REVIEW" and ask for clarification

**Last Updated**: [Update timestamp on each modification]
