# Arrow Puzzle Implementation Plan

## Executive Summary

This plan details the implementation of a third puzzle type ("Arrow Puzzle") for the Save the Christmas game, following established architecture patterns from Spiral Twist and Rectangle Jigsaw puzzles.

**Key Requirements:**
- Add Arrow Puzzle as third puzzle type with 3-way level rotation (Spiral → Rectangle → Arrow)
- Remove ALL hint systems from the entire game
- Implement arrow movement with collision detection and bounce-back animation
- Support grid sizes: 5×4=20 arrows (Easy), 6×5=30 arrows (Normal), 8×7=56 arrows (Hard)
- Background image visible with arrows overlaid on top
- Simple direction algorithm ensures solvability

---

## 1. Architecture Approach

### 1.1 Following Existing Patterns

The implementation will mirror the established architecture:

**State Class Pattern:**
- Create `ArrowPuzzleState` extending `Resource` (similar to `PuzzleState` and `SpiralPuzzleState`)
- Implements `is_puzzle_solved()` method returning `active_arrow_count == 0`

**Element Class Pattern:**
- Create `Arrow` class extending `Resource` (similar to `Tile` and `SpiralRing`)
- Stores arrow_id, grid_position, direction, has_exited, is_animating

**Node Rendering Pattern:**
- Create `arrow_node.tscn` + `arrow_node.gd` (similar to `tile_node` and `spiral_ring_node`)
- Uses TextureRect with rotation applied to single up_arrow.png asset

**Routing Pattern:**
- String-based type routing in `puzzle_manager.gd` ("arrow_puzzle")
- Type detection in `gameplay_screen.gd` via `is ArrowPuzzleState` check

### 1.2 Level Rotation Change (2-way → 3-way)

**Current:**
- Odd levels (1, 3, 5...) = Spiral Twist
- Even levels (2, 4, 6...) = Rectangle Jigsaw

**New:**
- Level % 3 == 1 (1, 4, 7, 10...) = Spiral Twist
- Level % 3 == 2 (2, 5, 8, 11...) = Rectangle Jigsaw
- Level % 3 == 0 (3, 6, 9, 12...) = Arrow Puzzle

---

## 2. Arrow Puzzle Mechanics

### 2.1 Core Gameplay

1. **Visual Setup:**
   - Full level image displayed as background (visible, not obscured)
   - Grid of arrows overlaid on top with semi-transparent white backgrounds
   - Each arrow shows direction (UP/DOWN/LEFT/RIGHT) using rotated up_arrow.png

2. **Interaction:**
   - Tap an arrow → attempt to move in its direction
   - Movement traces path until: (a) exits boundary = success, or (b) hits another arrow = blocked

3. **Success Path:**
   - Arrow immediately disappears (no animation per user requirement)
   - active_arrow_count decrements
   - Puzzle solves when all arrows have exited

4. **Blocked Path:**
   - Arrow bounces back to original position with 0.2s animation
   - Play error sound effect
   - Arrow remains in play

### 2.2 Direction Generation Algorithm (Simplistic)

To ensure solvability, all arrows in a puzzle use only **2 allowed directions**:

**Direction Sets (pick one randomly):**
1. 25% chance: LEFT or UP only
2. 25% chance: LEFT or DOWN only
3. 25% chance: RIGHT or UP only
4. 25% chance: RIGHT or DOWN only

**Per-Arrow Assignment:**
- Each arrow randomly picks one of the two allowed directions (50/50)

**Why Solvable:**
- All arrows can exit in their respective directions (left/right → side edges, up/down → top/bottom edges)
- No permanent deadlocks possible
- Player strategy: Tap edge arrows first, work inward

---

## 3. New Files to Create

### 3.1 `save-the-christmas/scripts/arrow.gd` (~70 lines)

**Purpose:** Arrow element data class

```gdscript
class_name Arrow
extends Resource

enum Direction { UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3 }

var arrow_id: int = 0
var grid_position: Vector2i = Vector2i(0, 0)
var direction: Direction = Direction.UP
var has_exited: bool = false
var is_animating: bool = false

# Returns rotation in degrees for rendering
func get_rotation_degrees() -> float

# Returns Vector2i for movement calculations
func get_direction_vector() -> Vector2i

# Checks if this arrow blocks a given grid position
func blocks_position(check_pos: Vector2i) -> bool
```

---

### 3.2 `save-the-christmas/scripts/arrow_puzzle_state.gd` (~130 lines)

**Purpose:** Arrow puzzle state and movement logic

```gdscript
class_name ArrowPuzzleState
extends Resource

var level_id: int
var difficulty: String
var grid_size: Vector2i  # (columns, rows)
var arrows: Array[Arrow]
var active_arrow_count: int
var tap_count: int
var direction_set: Array[int]  # Two allowed directions
var is_solved: bool = false

# Win condition
func is_puzzle_solved() -> bool:
    return active_arrow_count == 0

# Find arrow at grid coordinates
func get_arrow_at_position(pos: Vector2i) -> Arrow

# Check if position blocked by another arrow (excluding specific ID)
func is_position_blocked(pos: Vector2i, excluding_id: int) -> bool

# Core movement logic: trace path, detect collision/exit
func attempt_arrow_movement(arrow_id: int) -> Dictionary:
    # Returns: {success: bool, blocked_by: int or -1}
```

**Movement Algorithm:**
1. Get arrow by ID, verify not exited/animating
2. Trace path step-by-step in direction
3. Each step: check if out of bounds (exit success) or blocked by another arrow
4. Return result with success flag and blocking arrow ID if applicable

---

### 3.3 `save-the-christmas/scripts/arrow_node.gd` (~120 lines)

**Purpose:** Visual arrow node with tap handling and animations

```gdscript
extends Control

signal arrow_tapped(arrow_id: int)

var arrow_data: Arrow
var arrow_texture: TextureRect
var original_position: Vector2

# Initialize with arrow data
func setup(arrow: Arrow, texture_path: String) -> void

# Animate immediate disappearance (fade out 0.15s)
func animate_exit() -> void

# Animate bounce back to original position (0.2s)
func animate_bounce() -> void

# Handle tap input
func _on_gui_input(event: InputEvent) -> void
```

---

### 3.4 `save-the-christmas/scenes/arrow_node.tscn` (~40 lines)

**Purpose:** Arrow node scene structure

**Hierarchy:**
```
Control (arrow_node.gd)
├── Background (Panel - white with transparency)
├── ArrowTexture (TextureRect - rotated up_arrow.png)
└── TouchArea (Control - input capture)
```

**Configuration:**
- Root Control: custom_minimum_size based on grid calculations
- ArrowTexture: expand_mode = EXPAND_FIT_WIDTH_PROPORTIONAL
- Rotation applied via `rotation_degrees` property

---

## 4. Files to Modify

### 4.1 `save-the-christmas/scripts/game_constants.gd`

**Add constants after line 32:**
```gdscript
# Arrow Puzzle mechanics
const ARROW_BOUNCE_DURATION = 0.2  # Bounce-back animation
const ARROW_EXIT_DURATION = 0.15   # Fade-out on success
const ARROW_GRID_SPACING = 10      # Pixels between arrows

# Arrow grid sizes per difficulty
const ARROW_GRID_EASY = Vector2i(5, 4)    # 20 arrows
const ARROW_GRID_NORMAL = Vector2i(6, 5)  # 30 arrows
const ARROW_GRID_HARD = Vector2i(8, 7)    # 56 arrows

const ARROW_TEXTURE_PATH = "res://assets/ui/up_arrow.png"
```

**Modify PuzzleType enum (line 49):**
```gdscript
enum PuzzleType {
    RECTANGLE_JIGSAW = 0,
    SPIRAL_TWIST = 1,
    ARROW_PUZZLE = 2  # ADD THIS
}
```

---

### 4.2 `save-the-christmas/scripts/puzzle_manager.gd`

**Changes:**

1. **Add preloads (after line 7):**
   ```gdscript
   const ArrowPuzzleState = preload("res://scripts/arrow_puzzle_state.gd")
   const Arrow = preload("res://scripts/arrow.gd")
   ```

2. **Modify generate_puzzle() routing (line 20-23):**
   ```gdscript
   if puzzle_type == "spiral_twist":
       return _generate_spiral_puzzle(level_id, difficulty, level_data)
   elif puzzle_type == "arrow_puzzle":
       return _generate_arrow_puzzle(level_id, difficulty, level_data)
   else:
       return _generate_rectangle_puzzle(level_id, difficulty, level_data)
   ```

3. **Add new generation methods (after line 180):**
   - `_generate_arrow_puzzle(level_id, difficulty, level_data) -> ArrowPuzzleState`
   - `_get_arrow_grid_size(difficulty: String) -> Vector2i`
   - `_create_arrows_for_grid(grid_size: Vector2i, direction_set: Array) -> Array[Arrow]`

4. **Remove hint method:**
   - Delete `use_hint()` method entirely (lines 262-294)

**Generation Logic:**
```gdscript
func _generate_arrow_puzzle(...) -> ArrowPuzzleState:
    # 1. Get grid_size from difficulty config or default
    # 2. Pick random direction set (one of 4 pairs)
    # 3. Create arrows with random directions from set
    # 4. Return populated ArrowPuzzleState
```

---

### 4.3 `save-the-christmas/scripts/gameplay_screen.gd`

**Changes:**

1. **Add preloads (after line 10):**
   ```gdscript
   const ArrowPuzzleState = preload("res://scripts/arrow_puzzle_state.gd")
   const ARROW_NODE_SCENE = preload("res://scenes/arrow_node.tscn")
   ```

2. **Add state variables (after line 21):**
   ```gdscript
   var is_arrow_puzzle: bool = false
   var arrow_nodes: Array = []
   var arrows_container: Control = null
   var background_image: TextureRect = null
   ```

3. **Modify _initialize_gameplay() (line 56):**
   ```gdscript
   is_spiral_puzzle = puzzle_state is SpiralPuzzleState
   is_arrow_puzzle = puzzle_state is ArrowPuzzleState

   if is_spiral_puzzle:
       _setup_spiral_puzzle()
       await _spawn_spiral_rings()
   elif is_arrow_puzzle:
       _setup_arrow_puzzle()
       _spawn_arrows()
   else:
       _setup_puzzle_grid()
       _spawn_tiles()
   ```

4. **Add new methods (after line 542):**
   - `_setup_arrow_puzzle()` - Create background image + arrows container
   - `_spawn_arrows()` - Create grid of arrow nodes
   - `_calculate_arrow_size(grid_size: Vector2i) -> Vector2` - Size based on puzzle area
   - `_on_arrow_tapped(arrow_id: int)` - Handle tap, call movement logic, animate
   - `_check_arrow_puzzle_solved()` - Win condition + progression
   - `_save_arrow_progress()` - Save stars and unlock levels

5. **Remove hint-related code:**
   - Remove `@onready var hint_button` reference (line 26)
   - Delete `_on_hint_button_pressed()` method (lines 226-257)
   - Remove hint button signal connection

**Arrow Tap Handler Logic:**
```gdscript
func _on_arrow_tapped(arrow_id: int):
    var result = arrow_puzzle_state.attempt_arrow_movement(arrow_id)
    var arrow_node = arrow_nodes[arrow_id]

    if result.success:
        arrow_node.animate_exit()
        await arrow_node.tree_exited
        arrow_puzzle_state.active_arrow_count -= 1
        _check_arrow_puzzle_solved()
    else:
        arrow_node.animate_bounce()
        AudioManager.play_sfx("error")  # or similar
```

---

### 4.4 `save-the-christmas/scripts/level_manager.gd`

**Modify _generate_dynamic_level() (lines 82-139):**

1. **Change puzzle type determination (3-way rotation):**
   ```gdscript
   var puzzle_type: String
   var mod_result = level_id % 3
   if mod_result == 1:
       puzzle_type = "spiral_twist"
   elif mod_result == 2:
       puzzle_type = "rectangle_jigsaw"
   else:  # mod_result == 0
       puzzle_type = "arrow_puzzle"
   ```

2. **Add arrow_puzzle difficulty configs:**
   ```gdscript
   elif puzzle_type == "arrow_puzzle":
       difficulty_configs = {
           "easy": {"grid_size": GameConstants.ARROW_GRID_EASY},
           "normal": {"grid_size": GameConstants.ARROW_GRID_NORMAL},
           "hard": {"grid_size": GameConstants.ARROW_GRID_HARD}
       }
   ```

3. **Change hint_limit for all puzzles:**
   ```gdscript
   "hint_limit": 0,  # Changed from GameConstants.DEFAULT_HINT_LIMIT
   ```

---

### 4.5 `save-the-christmas/data/levels.json`

**Changes:**

1. **Update all existing levels:**
   - Change `"hint_limit": 3` to `"hint_limit": 0` for all levels

2. **Add Level 3 (first arrow puzzle):**
   ```json
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
     "hint_limit": 0,
     "tags": ["village", "snow", "outdoor"]
   }
   ```

---

### 4.6 `save-the-christmas/scenes/gameplay_screen.tscn`

**Remove hint button UI:**
- Delete HintButton node from BottomHUD container
- Adjust BottomHUD layout (re-center remaining buttons if needed)

---

### 4.7 `save-the-christmas/scripts/spiral_puzzle_state.gd`

**Remove hint method:**
- Delete `use_hint()` method (lines 100-122)
- Keep `hints_used` field for save file compatibility (always remains 0)

---

## 5. Implementation Sequence

### Phase 1: Core Data Structures (2-3 hours)
1. Create `arrow.gd` with Direction enum and helper methods
2. Create `arrow_puzzle_state.gd` with movement/collision logic
3. Add constants to `game_constants.gd`
4. **Validate:** Run `--check-only` on all new scripts

### Phase 2: Visual Node (1-2 hours)
5. Create `arrow_node.tscn` scene structure
6. Create `arrow_node.gd` with tap handling and animations
7. **Validate:** Test scene in isolation if possible

### Phase 3: Generation & Routing (2-3 hours)
8. Modify `puzzle_manager.gd` - add routing and generation methods
9. Modify `level_manager.gd` - implement 3-way rotation
10. Update `levels.json` - add Level 3, set all hint_limit to 0
11. **Validate:** Check JSON syntax, run script validation

### Phase 4: Gameplay Integration (3-4 hours)
12. Modify `gameplay_screen.gd` - add arrow puzzle setup and handling
13. Implement `_on_arrow_tapped()` with movement logic
14. Implement `_check_arrow_puzzle_solved()` and progress saving
15. **Validate:** End-to-end test levels 1-6

### Phase 5: Hint Removal (1-2 hours)
16. Remove HintButton from `gameplay_screen.tscn`
17. Remove hint methods from `puzzle_manager.gd` and `spiral_puzzle_state.gd`
18. Remove hint-related code from `gameplay_screen.gd`
19. **Validate:** Test all three puzzle types complete without errors

### Phase 6: Polish & Testing (2-3 hours)
20. Test all difficulties (Easy/Normal/Hard)
21. Verify save/load works correctly
22. Test level rotation (1=Spiral, 2=Rect, 3=Arrow, 4=Spiral, etc.)
23. Polish animations (bounce timing, exit fade)
24. Add/verify error sound effect

**Estimated Total: 11-17 hours**

---

## 6. Testing Checklist

### Arrow Puzzle Core
- [ ] Arrows spawn in correct grid positions (centered in puzzle area)
- [ ] Arrow rotation matches direction (UP=0°, RIGHT=90°, DOWN=180°, LEFT=270°)
- [ ] Direction set randomly selects one of 4 pairs each puzzle generation
- [ ] Each arrow correctly picks from the two allowed directions
- [ ] Background image displays full level image behind arrows

### Movement & Collision
- [ ] Tap arrow with clear path → exits immediately (disappears)
- [ ] Tap arrow with blocked path → bounces back with 0.2s animation
- [ ] Exited arrows don't block new movement paths
- [ ] Can't tap during animation (is_animating flag prevents double-tap)
- [ ] All arrows exit → puzzle solves, stars awarded, progress saved

### Level Rotation (3-way)
- [ ] Level 1 = Spiral Twist
- [ ] Level 2 = Rectangle Jigsaw
- [ ] Level 3 = Arrow Puzzle
- [ ] Level 4 = Spiral Twist (cycle repeats)
- [ ] Level 5 = Rectangle Jigsaw
- [ ] Level 6 = Arrow Puzzle

### Hint System Removal
- [ ] No hint button visible on any screen
- [ ] No hint methods called in any script
- [ ] All puzzle types complete successfully without hints
- [ ] levels.json updated (all hint_limit: 0)
- [ ] No runtime errors related to missing hint methods

### Save/Load
- [ ] Arrow puzzle progress saves correctly
- [ ] Stars awarded based on difficulty (Easy=1, Normal=2, Hard=3)
- [ ] Next level unlocks after completing Easy
- [ ] Difficulty unlocks work (Normal after Easy, Hard after Normal)

---

## 7. Critical Files Summary

### New Files (4)
1. `save-the-christmas/scripts/arrow.gd` - Arrow element class
2. `save-the-christmas/scripts/arrow_puzzle_state.gd` - Arrow puzzle state
3. `save-the-christmas/scripts/arrow_node.gd` - Arrow visual node
4. `save-the-christmas/scenes/arrow_node.tscn` - Arrow node scene

### Modified Files (7)
1. `save-the-christmas/scripts/game_constants.gd` - Add arrow constants
2. `save-the-christmas/scripts/puzzle_manager.gd` - Add generation, remove hints
3. `save-the-christmas/scripts/gameplay_screen.gd` - Add arrow setup, remove hints
4. `save-the-christmas/scripts/level_manager.gd` - 3-way rotation, remove hints
5. `save-the-christmas/scripts/spiral_puzzle_state.gd` - Remove hint method
6. `save-the-christmas/data/levels.json` - Add level 3, set hint_limit=0
7. `save-the-christmas/scenes/gameplay_screen.tscn` - Remove hint button

---

## 8. Key Design Decisions

### Why Grid-Based (Not Free-Floating)
- Simplifies collision detection (grid coordinate checking)
- Clear visual layout for player understanding
- Consistent with Rectangle Jigsaw grid pattern

### Why Immediate Exit (Not Animated)
- Per user requirement
- Reduces visual clutter as arrows disappear
- Faster puzzle completion feedback

### Why Bounce Animation for Blocked
- Clear visual feedback that move failed
- Maintains arrow position (doesn't leave player confused)
- 0.2s duration matches game's other quick animations

### Why 2-Direction Algorithm (Not Random All 4)
- Guarantees solvability without complex solver logic
- Still provides variety (4 different direction pairs)
- Simple to implement and test
- Player can develop strategy (work from edges inward)

### Why Remove All Hints
- Per user requirement
- Simplifies codebase (removes entire subsystem)
- Maintains challenge across all puzzle types

---

## 9. Rationale & Architecture Alignment

This implementation plan follows the established patterns from existing puzzle types:

1. **Polymorphic State Pattern:** ArrowPuzzleState extends Resource, implements is_puzzle_solved()
2. **String-Based Routing:** "arrow_puzzle" added to puzzle_manager.gd dispatch logic
3. **Type Detection:** `is ArrowPuzzleState` check in gameplay_screen.gd
4. **Difficulty Configs:** JSON schema matches existing pattern (grid_size for arrow_puzzle)
5. **Progression System:** Uses same ProgressManager.set_star() and save logic
6. **Scene Navigation:** Calls same _handle_puzzle_completion() method

The 3-way level rotation is a minimal change to level_manager.gd (% 3 instead of % 2), maintaining backward compatibility with existing level data while supporting the new puzzle type.

Hint removal is clean: delete UI elements, remove methods, set hint_limit to 0. No breaking changes to save file format (hints_used field remains, just always 0).

---

**End of Plan**
