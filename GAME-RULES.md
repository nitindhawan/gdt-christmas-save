# Save the Christmas - Game Rules

**Related Documentation**:
- **DATA-SCHEMA.md** - Data structures, save data format
- **SCREEN-REQUIREMENTS.md** - UI layouts and visual specifications
- **ARCHITECTURE-MASTER.md** - System architecture overview

---

## Game Objective
Unscramble beautiful Christmas-themed images by rearranging jumbled rectangular tiles into their correct positions. Complete levels across three difficulty settings to earn up to 3 stars per level.

## Puzzle Type: Rectangle Jigsaw

### Grid System
Each level image is divided into a rectangular grid of tiles:
- **Easy**: 2×3 grid (6 tiles) - Low complexity, ~30-60 seconds to solve
- **Normal**: 3×4 grid (12 tiles) - Medium complexity, ~2-4 minutes to solve
- **Hard**: 5×6 grid (30 tiles) - High complexity, ~5-10 minutes to solve

### Tile Properties
- Each tile displays a portion of the source image
- Tiles are rectangular sections with equal dimensions
- Some parts of the image may extend outside the tile boundaries (decorative borders)
- Each tile has a unique correct position in the grid

---

## Gameplay Mechanics

### Level Start
1. Player selects a level from Level Selection screen
2. For new levels: Automatically start in Easy difficulty
3. For beaten levels: Player selects difficulty (Easy/Normal/Hard)
4. Gameplay screen loads with tiles pre-scrambled using Fisher-Yates shuffle
5. Scrambling ensures puzzle requires meaningful swaps (not just 1-2 moves)

### Player Interaction: Two-Tap Swap
1. **First tap**: Player taps a tile
   - Selected tile highlights with border or scale effect
   - Visual feedback confirms selection
2. **Second tap**: Player taps another tile
   - Both tiles swap positions with smooth animation (~0.3s ease-in-out)
   - Selection highlight clears after swap
3. **Repeat**: Continue swapping until puzzle is solved

**Alternative (Optional)**: Drag and drop - Drag a tile over another to swap positions

### Invalid Actions
- Tapping same tile twice: Deselects the tile (cancel selection)
- Tapping outside grid: Deselects currently selected tile
- Rapid tapping: Debounced to prevent multiple simultaneous swaps

### Hint System
- **Location**: Button at bottom of Gameplay Screen
- **Action**: Automatically swaps one incorrectly placed tile to its correct position
- **Limitation**: 3 hints per level (configurable in levels.json)
- **Visual Feedback**: Sparkle/glow animation on hinted tile
- **Cost**: Free in MVP (future: rewarded video ads for additional hints)

### Win Condition
- Puzzle is solved when ALL tiles are in their correct positions
- Validation: Compare each tile's `current_position` with `correct_position`
- On win:
  1. Play victory jingle sound effect
  2. Display completion animation (confetti/sparkle effect)
  3. Transition to Level Complete Screen after 1-second delay

---

## Progression System

### Star Collection
- Each level can earn up to **3 stars** (one per difficulty)
- Star awards:
  - **Easy**: 1 star ⭐
  - **Normal**: 2 stars ⭐⭐
  - **Hard**: 3 stars ⭐⭐⭐
- Stars are cumulative: Completing Hard awards all 3 stars, even if Easy/Normal not played

### Unlock Logic

**Starting state:**
- Level 1 unlocked on Easy difficulty
- All other levels locked

**Rules:**
1. **Complete Easy of Level N** → Unlocks Level N+1 Easy + Level N Normal
2. **Complete Normal of Level N** → Unlocks Level N Hard
3. **Complete Hard** → No additional unlocks (all 3 stars earned)

**Example Progression:**
```
Initial:          Level 1 Easy ✓ | Levels 2-20 locked
After L1 Easy:    Level 1 Easy(1⭐) + Normal ✓ | Level 2 Easy ✓ | Levels 3-20 locked
After L1 Normal:  Level 1 Easy+Normal(2⭐⭐) + Hard ✓ | Level 2 Easy ✓ | Levels 3-20 locked
After L2 Easy:    Level 1 (2⭐⭐+Hard) | Level 2 Easy(1⭐) + Normal ✓ | Level 3 Easy ✓ | Levels 4-20 locked
```

### Progress Persistence
- Saved locally using Godot's ConfigFile (user://save_data.cfg)
- Save triggers: Level completion, returning to Level Selection, app pause/background
- Saved data: Highest level unlocked, stars per level per difficulty, settings
- See **DATA-SCHEMA.md** for complete save data structure

---

## Level Selection Flows

### Scenario 1: Click Beaten Level (has stars)
- Navigate to Difficulty Selection screen
- Show full preview of level image
- Display difficulty buttons (green if unlocked, grey with lock if locked)
- Player selects difficulty → Gameplay screen

### Scenario 2: Click Unlocked Unbeaten Level (no stars)
- Directly navigate to Gameplay screen in Easy difficulty (skip Difficulty Selection)

### Scenario 3: Click Locked Level
- No action / Show "Complete previous level to unlock" tooltip

### Level Complete Flow
1. Display Level Complete screen with completed image
2. Award appropriate stars (1, 2, or 3 based on difficulty)
3. Save progress and unlock next level/difficulty
4. Player clicks "Continue":
   - If next level unlocked → Load next level on Easy
   - If last level (20) → Return to Level Selection
   - If completed Normal/Hard → Return to Level Selection (no auto-continue to other difficulties)

---

## Special Features

### Share Functionality
- **From Difficulty Selection**: Share level preview image
- **From Gameplay**: Share current puzzle state (scrambled)
- **From Level Complete**: Share completed image
- Opens native mobile share sheet (iOS/Android)
- Shared content: Image file + optional text ("I solved this Christmas puzzle!")

### Back Button During Gameplay
- Show confirmation dialog: "Exit level? Progress will not be saved."
- Options: "Stay" (cancel) / "Exit" (return to Level Selection)
- Note: MVP has no mid-level save (future enhancement: auto-save puzzle state)

### Settings During Gameplay
- Settings popup can be opened during active puzzle
- Game state preserved (tile positions, selection state)
- On closing settings: Resume gameplay immediately

---

## Audio & Haptic Feedback

### Audio Triggers
- **Tile Select**: Soft click when first tile selected
- **Tile Swap**: Swap/whoosh sound during tile exchange
- **Level Complete**: Victory jingle (cheerful Christmas melody)
- **Button Click**: Standard UI click for all buttons
- **Hint Used**: Special "magical" sound
- **Background Music**: Looping Christmas instrumentals (toggleable, low volume)

### Haptic Triggers
- **Tile Select**: Light tap
- **Tile Swap**: Medium pulse
- **Level Complete**: Success pattern
- All haptics toggleable via Settings popup

---

## Scoring & Failure Conditions

### MVP Approach
- **No scoring system**: Stars are the primary progression metric
- **No failure conditions**: Players can swap indefinitely until solved
- **No time limits**: Casual, relaxed gameplay

### Future Enhancements
- **Move Count**: Track swaps to solve
- **Time Taken**: Track solve time for leaderboards
- **Perfect Bonus**: Complete without hints for bonus stars
- **Timed Mode**: Complete within time limit
- **Move Limit Mode**: Solve within X swaps
- **Three-Star Requirements**: Stars based on time/moves (e.g., < 2min = 3⭐)

---

This document defines the complete gameplay rules and mechanics for "Save the Christmas" MVP.
