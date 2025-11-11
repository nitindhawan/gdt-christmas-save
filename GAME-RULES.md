# Save the Christmas - Game Rules

**Related Documentation**:
- **DATA-SCHEMA.md** - Data structures, save data format
- **SCREEN-REQUIREMENTS.md** - UI layouts and visual specifications
- **ARCHITECTURE-MASTER.md** - System architecture overview

---

## Game Objective
Solve beautiful Christmas-themed image puzzles in two distinct modes. Complete levels across three difficulty settings to earn up to 3 stars per level.

## Puzzle Types

The game features two puzzle mechanics that alternate between levels:
- **Odd-numbered levels (1, 3, 5, ...)**: Spiral Twist
- **Even-numbered levels (2, 4, 6, ...)**: Rectangle Jigsaw

---

## Puzzle Type 1: Spiral Twist

### Overview
Rotate concentric rings of a circular Christmas image to align them correctly. Rings can be dragged or flicked with momentum, and merge together when aligned.

### Ring System
- Image divided into concentric circular rings (3-7 rings based on difficulty)
- **Easy**: 3 rings - Quick to solve, ~1-2 minutes
- **Normal**: 5 rings - Medium complexity, ~3-5 minutes
- **Hard**: 7 rings - High complexity, ~5-8 minutes
- **Outermost ring**: Static, doesn't rotate (serves as reference frame)
- **Ring borders**: 4px white border for visual separation

### Ring Properties
- Each ring can rotate independently around the puzzle center
- Rings have angular velocity and momentum (physics-based)
- Target: All rings at 0° rotation (correct alignment)
- Rings start scrambled at random angles (±180°, minimum 20° from correct)

### Gameplay Mechanics: Drag and Flick (IMPLEMENTED)

**Input Handling**: Centralized in rings_container (gameplay_screen.gd _on_rings_container_input)
- All touch events captured by single container Control node
- Hit detection finds which ring is at touch position (distance from center)
- Innermost rings prioritized if multiple rings overlap at touch point

#### Drag Rotation
1. **Touch down** on a ring (between inner and outer radius)
   - Container detects ring at touch position based on distance from center
   - Calls ring_node.start_drag_external(touch_pos)
   - Locked rings (is_locked=true) cannot be dragged
2. **Drag** finger around the puzzle center
   - Container tracks drag in _dragging_ring_node variable
   - Calls ring_node.update_drag_external(touch_pos) on motion events
   - Returns angle_delta which is applied via spiral_state.rotate_ring()
   - Ring rotates following finger position
   - Direct angle control (no momentum while dragging)
   - Visual feedback via ring_node.update_visual() (queue_redraw)
3. **Release** to stop dragging
   - Calls ring_node.end_drag_external()
   - Calculates flick velocity from last 3 touch samples (angle history + timestamps)
   - If release has velocity > 10°/s → Applies angular_velocity to ring
   - If release is slow → Ring stops immediately (velocity = 0)

#### Flick Momentum
- **Flick detection**: Calculated from last 3 touch samples during drag
- **Angular velocity**: Applied to ring on release (degrees per second)
- **Maximum velocity**: 720°/s (2 rotations per second)
- **Deceleration**: 200°/s² (ring gradually slows down)
- **Stop threshold**: Ring stops when velocity < 1.0°/s
- **Time to stop**: ~2-3 seconds from max velocity

### Ring Merging System (IMPLEMENTED)

**Physics Loop**: Runs in GameplayScreen._process(delta) every frame:
```gdscript
spiral_state.update_physics(delta)          # Update all ring rotations
if spiral_state.check_and_merge_rings():    # Check merges each frame
    AudioManager.play_sfx("ring_merge")
    _refresh_spiral_visuals()               # Update display after merge
    if spiral_state.is_puzzle_solved():
        _check_spiral_puzzle_solved()
```

#### Merge Conditions (ALL must be met)
1. Rings are adjacent (indices differ by exactly 1 in rings array)
2. **Angle alignment**: Angle difference ≤ 5° (SPIRAL_MERGE_ANGLE_THRESHOLD)
3. **Velocity alignment**: Angular velocity difference ≤ 10°/s (SPIRAL_MERGE_VELOCITY_THRESHOLD)
4. **Not both locked**: At least one ring must be unlocked (can_merge_with check)

#### Merge Behavior (spiral_puzzle_state.gd check_and_merge_rings)
When two adjacent rings align (angle ≤5°, velocity ≤10°/s):
1. **Keep the OUTER ring instance** (rings[i+1]), discard the inner ring (rings[i])
2. **Expand outer ring inward**: `outer_ring.inner_radius = inner_ring.inner_radius`
3. Call `outer_ring.merge_with(inner_ring)`:
   - Average angles: `(current_angle + other.current_angle) / 2`
   - Average velocities: `(angular_velocity + other.angular_velocity) / 2`
   - If merging with locked ring: Result inherits `is_locked = true`, velocity = 0
   - Track merged ring IDs in `merged_ring_ids` array
4. **Remove inner ring from rings array**: `rings.remove_at(i)`
5. **Decrement active_ring_count by 1**
6. **Result**: ONE wider ring that encompasses both original rings
7. **Visual feedback**: Border changes to dark gray when locked, ring_node expanded
8. **Audio**: "ring_merge" sound effect plays (in gameplay_screen)
9. **Break and re-check next frame** (array indices shifted after removal)

#### Locking System
- **Outermost ring**: Starts `is_locked = true` (the static reference frame)
- **Locked rings**: Cannot rotate, cannot be dragged, cannot gain velocity
- **When merging with locked ring**: Result inherits locked state
- **Progressive locking**: Rings merge inward until all are part of the locked outermost ring

#### Puzzle Solved Condition (IMPLEMENTED)
- **Win condition check**: `spiral_state.is_puzzle_solved()` returns `active_ring_count <= 1`
- **Actual implementation**: When `rings.size() == 1` (only locked outermost ring remains)
- **Progression**: Inner rings merge with neighbors → eventually merge with outermost → become locked
- Rings must be aligned (angle ≤5°) and have similar velocity (≤10°/s) to merge
- Victory triggers (in _check_spiral_puzzle_solved):
  - Play "level_complete" sound effect
  - Haptic feedback (0.8 intensity)
  - Save progress (stars, rotation_count, hints_used) via _save_spiral_progress()
  - Navigate to LevelCompleteScreen after 1 second delay

### Hint System (Spiral)
- **Action**: Snaps one random incorrect ring to 0° (correct angle)
- **Limitation**: 3 hints per level (configurable in levels.json)
- **Selection**: Randomly picks from rings not yet at correct angle
- **Effect**: Instant rotation to correct position (no animation)
- **Cost**: Free in MVP

### Physics Constants (GameConstants)
```
SPIRAL_MERGE_ANGLE_THRESHOLD = 5.0°        # Rings merge when within this angle
SPIRAL_MERGE_VELOCITY_THRESHOLD = 10.0°/s  # Velocity difference for merge
SPIRAL_ANGULAR_DECELERATION = 200.0°/s²    # Friction/slowdown rate
SPIRAL_MAX_ANGULAR_VELOCITY = 720.0°/s     # Maximum flick speed
SPIRAL_MIN_VELOCITY_THRESHOLD = 1.0°/s     # Stop completely below this
SPIRAL_ROTATION_SNAP_ANGLE = 1.0°          # Considered correct within this
SPIRAL_RING_BORDER_WIDTH = 4px             # Visual border thickness
```

### Invalid Actions
- Tapping merged rings: No effect (ring locked)
- Tapping outside puzzle area: No effect
- Tapping center or outside outermost ring: No effect

---

## Puzzle Type 2: Rectangle Jigsaw

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

### Hint System (Rectangle Jigsaw)
- **Location**: Button at bottom of Gameplay Screen
- **Action**: Automatically swaps one incorrectly placed tile to its correct position
- **Limitation**: 3 hints per level (configurable in levels.json)
- **Visual Feedback**: Sparkle/glow animation on hinted tile
- **Cost**: Free in MVP (future: rewarded video ads for additional hints)

### Win Condition (Rectangle Jigsaw)
- Puzzle is solved when ALL tiles are in their correct positions
- Validation: Compare each tile's `current_position` with `correct_position`
- On win:
  1. Play victory jingle sound effect
  2. Display completion animation (confetti/sparkle effect)
  3. Transition to Level Complete Screen after 1-second delay

### Win Condition (Spiral Twist)
- Puzzle is solved when only 1 active ring remains (all merged)
- All rings must be aligned within ±1° of correct angle (0°)
- On win:
  1. Play "level_complete" sound effect
  2. Trigger haptic feedback (0.8 intensity)
  3. Save progress (stars, rotation count, hints used)
  4. Transition to Level Complete Screen

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

#### Rectangle Jigsaw
- **Tile Select**: Soft click when first tile selected ("tile_pickup")
- **Tile Swap**: Swap/whoosh sound during tile exchange ("tile_drop")
- **Hint Used**: Special "magical" sound

#### Spiral Twist
- **Ring Touch**: Soft pickup sound on drag start ("tile_pickup")
- **Ring Release**: Drop sound on drag end ("tile_drop")
- **Ring Merge**: Special merge sound when rings lock together ("ring_merge")

#### Common
- **Level Complete**: Victory jingle (cheerful Christmas melody)
- **Button Click**: Standard UI click for all buttons
- **Background Music**: Looping Christmas instrumentals (toggleable, low volume)

### Haptic Triggers
- **Tile Select / Ring Touch**: Light tap
- **Tile Swap / Ring Merge**: Medium pulse
- **Level Complete**: Success pattern (0.8 intensity for Spiral)
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
