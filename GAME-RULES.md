# Save the Christmas - Game Rules

## Game Objective
Unscramble beautiful Christmas-themed images by rearranging jumbled rectangular tiles into their correct positions. Complete levels across three difficulty settings to earn up to 3 stars per level.

## Puzzle Type: Rectangle Jigsaw

### Grid System
Each level image is divided into a rectangular grid of tiles:
- **Easy**: 2 rows × 3 columns = 6 tiles
- **Normal**: 3 rows × 4 columns = 12 tiles
- **Hard**: 5 rows × 6 columns = 30 tiles

### Tile Properties
- Each tile displays a portion of the source image
- Tiles are rectangular sections with equal dimensions
- Some parts of the image may extend outside the tile boundaries (decorative borders)
- Each tile has a unique correct position in the grid

## Gameplay Mechanics

### Level Start
1. Player selects a level from Level Selection screen
2. For new levels: Automatically start in Easy difficulty
3. For beaten levels: Player selects difficulty (Easy/Normal/Hard)
4. Gameplay screen loads with tiles pre-scrambled
5. Timer starts (optional for MVP, planned for future "Timed Mode")

### Tile Scrambling
- At level start, tiles are randomly shuffled using a guaranteed-solvable algorithm
- Scrambling ensures the puzzle requires meaningful swaps (not just 1-2 moves)
- Scrambling algorithm: Fisher-Yates shuffle with validation to avoid trivial solutions

### Player Interaction: Two-Tap Swap
1. **First tap**: Player taps a tile
   - Selected tile highlights with border or scale effect
   - Visual feedback confirms selection
2. **Second tap**: Player taps another tile
   - Both tiles swap positions with smooth animation
   - Tween animation: 0.3 seconds ease-in-out
   - Selection highlight clears after swap
3. **Repeat**: Continue swapping until puzzle is solved

### Alternative Interaction: Drag and Drop (Optional)
- Player drags a tile over another tile
- On release, tiles swap positions
- Visual feedback: Dragged tile follows cursor/touch, target tile highlights

### Hint System
- **Hint Button**: Located at bottom of Gameplay Screen
- **Action**: Automatically swaps one incorrectly placed tile to its correct position
- **Limitation**: Limited hints per level (e.g., 3 hints max) - to be configured
- **Visual Feedback**: Hint tile swaps with sparkle/glow animation

### Win Condition
- Puzzle is solved when ALL tiles are in their correct positions
- Validation: Compare each tile's current_position with correct_position
- On win:
  1. Play victory jingle sound effect
  2. Display completion animation (optional: confetti, sparkle effect)
  3. Transition to Level Complete Screen after 1-second delay

## Progression System

### Star Collection
- Each level can earn up to **3 stars** (one per difficulty)
- Star awards:
  - **Easy**: 1 star ⭐
  - **Normal**: 2 stars ⭐⭐ (replaces Easy star if already earned)
  - **Hard**: 3 stars ⭐⭐⭐ (replaces previous stars if already earned)
- Stars are cumulative: Completing Hard awards all 3 stars, even if Easy/Normal not played

### Unlock Logic
Starting state:
- Level 1 unlocked on Easy difficulty
- All other levels locked

**Rule 1: Complete Easy difficulty of Level N**
- Unlock Level N+1 on Easy difficulty
- Unlock Level N on Normal difficulty

**Rule 2: Complete Normal difficulty of Level N**
- Unlock Level N on Hard difficulty

**Rule 3: Complete Hard difficulty**
- No additional unlocks (all 3 stars earned for Level N)

### Unlock Examples
```
Initial State:
  Level 1: Easy unlocked
  Level 2-20: Locked

After completing Level 1 Easy:
  Level 1: Easy (1⭐), Normal unlocked
  Level 2: Easy unlocked
  Level 3-20: Locked

After completing Level 1 Normal:
  Level 1: Easy + Normal (2⭐⭐), Hard unlocked
  Level 2: Easy unlocked
  Level 3-20: Locked

After completing Level 2 Easy:
  Level 1: Easy + Normal (2⭐⭐), Hard unlocked
  Level 2: Easy (1⭐), Normal unlocked
  Level 3: Easy unlocked
  Level 4-20: Locked

After completing Level 1 Hard:
  Level 1: Easy + Normal + Hard (3⭐⭐⭐)
  Level 2: Easy (1⭐), Normal unlocked
  Level 3: Easy unlocked
  Level 4-20: Locked
```

### Progress Persistence
- All progress saved locally using Godot's ConfigFile (user://save_data.cfg)
- Save triggers:
  - On level completion (star earned)
  - On returning to Level Selection screen
  - On app pause/background (mobile lifecycle)
- Save data includes:
  - Current highest level unlocked
  - Stars earned per level (easy/normal/hard flags)
  - Settings preferences

## Difficulty Differences

### Easy Mode (2×3 grid)
- **Tiles**: 6 tiles total
- **Complexity**: Low - Easy to visualize complete image
- **Target Audience**: Casual players, children
- **Average Solve Time**: 30-60 seconds

### Normal Mode (3×4 grid)
- **Tiles**: 12 tiles total
- **Complexity**: Medium - Requires strategic swapping
- **Target Audience**: Regular players
- **Average Solve Time**: 2-4 minutes

### Hard Mode (5×6 grid)
- **Tiles**: 30 tiles total
- **Complexity**: High - Challenging pattern recognition
- **Target Audience**: Puzzle enthusiasts
- **Average Solve Time**: 5-10 minutes

## Scoring System (Future Enhancement)
For MVP, no scoring system. Stars are the primary progression metric.

Future considerations:
- **Move Count**: Track number of swaps to solve
- **Time Taken**: Track solve time for leaderboards
- **Perfect Bonus**: Complete without hints for bonus stars
- **Streak System**: Complete multiple levels consecutively for bonuses

## Game Over / Failure Conditions
**MVP**: No failure conditions. Players can swap tiles indefinitely until solved.

**Future Enhancements**:
- **Timed Mode**: Complete puzzle within time limit
- **Move Limit**: Solve puzzle within X number of swaps
- **Three-Star Requirements**: Stars based on time/moves (e.g., < 2min = 3⭐)

## Level Selection Rules

### From Level Selection Screen
**Scenario 1: Click on beaten level (has stars)**
- Navigate to Difficulty Selection screen
- Show full preview of level image
- Display difficulty buttons (Easy/Normal/Hard)
- Green buttons for unlocked difficulties
- Grey buttons with lock icon for locked difficulties
- Player selects difficulty → Gameplay screen with selected difficulty

**Scenario 2: Click on unlocked but unbeaten level (no stars)**
- Directly navigate to Gameplay screen
- Automatically start in Easy difficulty (no difficulty selection)

**Scenario 3: Click on locked level**
- No action / Show "Complete previous level to unlock" tooltip

### Level Complete Flow
**On completing a level:**
1. Display Level Complete screen with completed image
2. Award appropriate stars (1, 2, or 3 based on difficulty)
3. Save progress and unlock next level/difficulty
4. Player clicks "Continue":
   - If next level exists and is now unlocked → Load next level on Easy
   - If last level (Level 20) → Return to Level Selection screen
   - If player completed Normal/Hard → Return to Level Selection (no auto-continue to same level different difficulty)

## Special Features

### Share Functionality
- **From Difficulty Selection**: Share level preview image
- **From Gameplay**: Share current puzzle state (scrambled tiles)
- **From Level Complete**: Share completed beautiful image
- Action: Opens native mobile share sheet (iOS/Android)
- Shared content: Image file + optional text ("I solved this Christmas puzzle!")

### Hint System Details
- **Hint Button**: Always visible in Gameplay screen
- **Cost**: Free in MVP (no hint economy)
- **Behavior**:
  1. Find all incorrectly placed tiles
  2. Randomly select one incorrect tile
  3. Find the tile currently in the correct position
  4. Swap the two tiles automatically with animation
- **Edge Case**: If only 2 tiles swapped, one hint solves the puzzle
- **Future**: Limit hints per level (e.g., 3 hints), rewarded video ads for more hints

## Audio Feedback

### Sound Effects
- **Tile Select**: Soft click sound when first tile selected
- **Tile Swap**: Satisfying swap/whoosh sound during tile exchange
- **Level Complete**: Victory jingle (cheerful Christmas melody)
- **Button Click**: Standard UI click for all buttons
- **Hint Used**: Special "magical" sound for hint activation

### Background Music
- **Looping Christmas Music**: Soft instrumental Christmas tunes
- **Volume**: Low volume to avoid distraction
- **Toggle**: Can be muted via Settings popup

### Haptic Feedback
- **Tile Select**: Light haptic tap
- **Tile Swap**: Medium haptic pulse
- **Level Complete**: Success haptic pattern
- **Toggle**: Can be disabled via Settings popup

## Edge Cases & Rules

### Invalid Actions
- Tapping same tile twice: Deselects the tile (cancel selection)
- Tapping outside grid: Deselects currently selected tile
- Rapid tapping: Debounce to prevent multiple simultaneous swaps

### Back Button Behavior
- **From Gameplay Screen**: Show confirmation dialog
  - "Exit level? Progress will not be saved."
  - Options: "Stay" (cancel) / "Exit" (return to Level Selection)
- Note: In MVP, no mid-level save. Future: Auto-save puzzle state.

### Settings During Gameplay
- Settings popup can be opened during active puzzle
- Game state preserved (tile positions, selection state)
- On closing settings: Resume gameplay immediately

### Level Complete Restrictions
- Cannot return to Gameplay after reaching Level Complete screen
- Must use Continue or Back to navigate away
- Download/Share buttons functional before continuing
