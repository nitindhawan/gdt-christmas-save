# Spiral Puzzle - Bugs and Fixes

## Bug 1: Incorrect Merge Implementation

### Current (Incorrect) Behavior
- When two rings merge, both ring instances remain
- Both get `is_merged = true` flag
- Both rings stop rotating
- Ring detection still checks both rings

### Correct Behavior (Design Intent)

#### Merge Process
When two rings merge (e.g., Ring 2 and Ring 3):
1. **Keep the OUTER ring instance** (Ring 3 in this example)
2. **Update outer ring's inner_radius**: `outer_ring.inner_radius = inner_ring.inner_radius`
3. **Average angles and velocities**: As currently done
4. **Discard/remove the inner ring** from the rings array
5. **Result**: ONE wider ring that spans both original radii

#### Locking Mechanism
- Use `is_locked` property (NOT `is_merged`)
- **Initialization**: Outermost ring starts with `is_locked = true`
- **When merging**: If merging WITH a locked ring, the result is locked
- **Locked rings**:
  - Cannot gain angular velocity
  - Cannot be dragged
  - Serve as the static reference frame

#### Velocity Control
- Add `gain_velocity(velocity: float)` method
  - Check `if is_locked: return`
  - Otherwise set `angular_velocity = clamp(velocity, -max, max)`

#### Drag Control
- Drag handling should check `if ring.is_locked: return` before allowing rotation

---

## Implementation Changes Needed

### File: `spiral_ring.gd`

**Add property**:
```gdscript
var is_locked: bool = false  # Whether ring is locked (cannot rotate)
```

**Remove property**:
```gdscript
var is_merged: bool = false  # ❌ DELETE THIS
```

**Add method**:
```gdscript
func gain_velocity(velocity: float) -> void:
    """Apply velocity from flick gesture"""
    if is_locked:
        return
    angular_velocity = clamp(velocity,
        -GameConstants.SPIRAL_MAX_ANGULAR_VELOCITY,
        GameConstants.SPIRAL_MAX_ANGULAR_VELOCITY)
```

**Update method**:
```gdscript
func can_merge_with(other_ring: SpiralRing) -> bool:
    # Remove: if is_merged or other_ring.is_merged
    if is_locked and other_ring.is_locked:  # Two locked rings can't merge
        return false

    # Check if rings are adjacent (indices differ by 1)
    if abs(ring_index - other_ring.ring_index) != 1:
        return false

    # Check angle/velocity differences (same as before)
    # ...
    return true
```

**Update method**:
```gdscript
func merge_with(other_ring: SpiralRing) -> void:
    """Merge this ring with another. This ring absorbs the other ring."""
    # Average angles
    current_angle = (_normalize_angle(current_angle) + _normalize_angle(other_ring.current_angle)) / 2.0

    # Average velocities
    angular_velocity = (angular_velocity + other_ring.angular_velocity) / 2.0

    # Expand inner radius to encompass merged ring
    inner_radius = min(inner_radius, other_ring.inner_radius)

    # If merging with locked ring, this ring becomes locked
    if other_ring.is_locked:
        is_locked = true
        angular_velocity = 0.0

    # Track merged ring IDs
    merged_ring_ids.append(other_ring.ring_index)
    for id in other_ring.merged_ring_ids:
        if id not in merged_ring_ids:
            merged_ring_ids.append(id)
```

**Update method**:
```gdscript
func update_rotation(delta: float) -> void:
    if is_locked:  # Changed from is_merged
        return

    # Apply velocity to angle
    current_angle += angular_velocity * delta
    current_angle = _normalize_angle(current_angle)

    # Apply deceleration (friction) - same as before
    # ...
```

**Update method** (new):
```gdscript
func can_rotate() -> bool:
    """Check if this ring can be rotated by user input"""
    return not is_locked
```

---

### File: `spiral_puzzle_state.gd`

**Update initialization**:
```gdscript
# In the code that creates rings (puzzle_manager.gd):
# Outermost ring (last in array) should have is_locked = true
for i in range(ring_count):
    var ring = SpiralRing.new()
    ring.ring_index = i
    # ... set radii, angles, etc ...

    # Lock the outermost ring
    if i == ring_count - 1:
        ring.is_locked = true
        ring.angular_velocity = 0.0

    rings.append(ring)
```

**Update method**:
```gdscript
func update_physics(delta: float) -> void:
    for ring in rings:
        if ring != null and not ring.is_locked:  # Changed from is_merged
            ring.update_rotation(delta)
```

**CRITICAL - Update method**:
```gdscript
func check_and_merge_rings() -> bool:
    var any_merged = false
    var rings_to_remove: Array[int] = []

    # Check adjacent rings for merge conditions
    for i in range(rings.size() - 1):
        var ring1 = rings[i]
        var ring2 = rings[i + 1]

        if ring1 == null or ring2 == null:
            continue

        if ring1.can_merge_with(ring2):
            # Keep the OUTER ring (ring2), merge inner into it
            ring2.inner_radius = ring1.inner_radius  # Expand inward
            ring2.current_angle = (ring1.current_angle + ring2.current_angle) / 2.0
            ring2.angular_velocity = (ring1.angular_velocity + ring2.angular_velocity) / 2.0

            # If either is locked, result is locked
            if ring1.is_locked or ring2.is_locked:
                ring2.is_locked = true
                ring2.angular_velocity = 0.0

            # Track merged IDs in outer ring
            ring2.merged_ring_ids.append(ring1.ring_index)
            for id in ring1.merged_ring_ids:
                if id not in ring2.merged_ring_ids:
                    ring2.merged_ring_ids.append(id)

            # Mark inner ring for removal
            rings_to_remove.append(i)
            active_ring_count -= 1
            any_merged = true

            # Play merge sound
            if AudioManager:
                AudioManager.play_sfx("ring_merge")

    # Remove merged rings (iterate backwards to preserve indices)
    for i in range(rings_to_remove.size() - 1, -1, -1):
        rings.remove_at(rings_to_remove[i])

    return any_merged
```

**Update method**:
```gdscript
func get_ring_at_position(touch_pos: Vector2, center: Vector2) -> int:
    var offset = touch_pos - center
    var distance = offset.length()

    # Find ring based on radial distance
    for i in range(rings.size()):
        var ring = rings[i]
        if ring != null and not ring.is_locked:  # Changed from is_merged
            if distance >= ring.inner_radius and distance <= ring.outer_radius:
                return i

    return -1
```

**Update method**:
```gdscript
func set_ring_velocity(ring_index: int, velocity: float) -> void:
    var ring = get_ring_by_index(ring_index)
    if ring != null:
        ring.gain_velocity(velocity)  # Use new method with is_locked check
        rotation_count += 1
```

**Update method**:
```gdscript
func rotate_ring(ring_index: int, angle_delta: float) -> void:
    var ring = get_ring_by_index(ring_index)
    if ring != null and ring.can_rotate():  # Use new method
        ring.current_angle += angle_delta
        ring.current_angle = ring._normalize_angle(ring.current_angle)
        rotation_count += 1
```

**Update method**:
```gdscript
func use_hint() -> int:
    var incorrect_rings = []

    # Find all rings that are not locked and not at correct angle
    for i in range(rings.size()):
        var ring = rings[i]
        if ring != null and not ring.is_locked and not ring.is_angle_correct():  # Changed
            incorrect_rings.append(i)

    # ... rest same
```

---

### File: `spiral_ring_node.gd`

**Update input handling**:
```gdscript
func _gui_input(event: InputEvent) -> void:
    # ... existing input filtering ...

    # Reject input for locked rings
    if ring_data.is_locked:  # Changed from is_merged
        return

    # ... rest of input handling
```

**Update visual rendering**:
```gdscript
func _draw_ring_border(center: Vector2) -> void:
    var border_color: Color

    if ring_data.is_locked:  # Changed from is_merged
        border_color = Color(0.3, 0.3, 0.3)  # Dark gray for locked
    else:
        border_color = Color.WHITE

    # ... draw borders
```

---

### File: `gameplay_screen.gd`

**Update visual refresh**:
```gdscript
func _refresh_spiral_visuals() -> void:
    # Update interactivity based on locked state
    for i in range(ring_nodes.size()):
        if i < spiral_state.rings.size():
            var ring = spiral_state.rings[i]
            ring_nodes[i].ring_data = ring
            ring_nodes[i].is_interactive = not ring.is_locked  # Changed
            ring_nodes[i].update_visual()
```

**Handle ring removal**: After merges, some ring nodes may need to be removed/hidden

---

## Summary of Changes

### Property Changes
- **Remove**: `is_merged`
- **Add**: `is_locked`

### Method Changes
- **Add**: `SpiralRing.gain_velocity()` - Checks `is_locked`
- **Add**: `SpiralRing.can_rotate()` - Returns `!is_locked`
- **Update**: `merge_with()` - Expand inner_radius, handle locking
- **Update**: `check_and_merge_rings()` - REMOVE inner ring after merge
- **Critical**: Ring array shrinks as rings merge!

### Initialization Changes
- Outermost ring starts with `is_locked = true`

### Win Condition
- Puzzle solved when `active_ring_count <= 1` (only locked ring remains)
- Actually: When `rings.size() == 1` might be clearer

---

## Additional Considerations

### Ring Node Management
- When a ring is removed from `spiral_state.rings[]`, the corresponding `ring_nodes[]` may become stale
- Need to either:
  1. Remove the ring node from scene tree
  2. Hide the ring node
  3. Re-map ring nodes to current ring indices

### Ring Index Updates
- After removing a ring, ring indices shift!
- Ring 0 merges with Ring 1 → Ring 0 removed → Former Ring 2 becomes Ring 1
- May need to update `ring_index` property after removal, OR
- Track rings by instance/ID instead of array index

### Recommended: Use Ring Instance References
Instead of passing `ring_index` in signals, pass ring instance or unique ID:
- `signal ring_rotated(ring: SpiralRing, angle_delta: float)`
- `signal ring_flicked(ring: SpiralRing, angular_velocity: float)`

This avoids index mismatches after array modifications.
