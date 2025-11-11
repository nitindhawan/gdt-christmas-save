# Spiral Ring Input Debug Guide

## Issue
Rings are not responding to drag/flick input.

## Diagnostic Steps

### 1. Check Console Output
When you click on a ring, you should see debug prints. Run the game and click on the inner rings (not the grey outermost ring). Check what prints appear:

**Expected prints on click**:
```
Ring X: GOT MOUSE EVENT! Size=..., Position=..., Event pos=...
Ring X: Mouse click at distance XXX (ring bounds: YYY-ZZZ)
Ring X: Started dragging at angle XXX
```

**If you see "Input ignored"**:
```
Ring X: Input ignored (interactive=false, locked=true)
```
This means either `is_interactive` is false or `is_locked` is true.

### 2. Check Ring Initialization
Add this debug print to `gameplay_screen.gd` after line 392:
```gdscript
ring_node.is_interactive = not ring.is_locked
print("Ring %d: is_locked=%s, is_interactive=%s, radii=%.1f-%.1f" % [
    i, ring.is_locked, ring_node.is_interactive, ring.inner_radius, ring.outer_radius
])
```

**Expected output** (for 3 rings, Easy mode):
```
Ring 2: is_locked=true, is_interactive=false, radii=300.0-450.0
Ring 1: is_locked=false, is_interactive=true, radii=150.0-300.0
Ring 0: is_locked=false, is_interactive=true, radii=0.0-150.0
```

### 3. Check Node Sizes
Add this debug print in `spiral_ring_node.gd` `_ready()` after line 42:
```gdscript
print("Ring %d: Mouse filter = %d, Visible = %s" % [ring_data.ring_index, mouse_filter, str(visible)])
print("Ring %d: Node size after layout = %v, Center = %v" % [ring_data.ring_index, size, size / 2.0])
print("Ring %d: Ring radii = %.1f to %.1f" % [ring_data.ring_index, ring_data.inner_radius, ring_data.outer_radius])
```

**Expected**: All rings should have size around (900, 900) and center at (450, 450).

### 4. Test Click Detection
Modify `_is_point_in_ring()` in `spiral_ring_node.gd` to add debug output:
```gdscript
func _is_point_in_ring(point: Vector2) -> bool:
    if ring_data == null:
        return false

    var local_center = size / 2.0
    var offset = point - local_center
    var distance = offset.length()
    var in_bounds = distance >= ring_data.inner_radius and distance <= ring_data.outer_radius

    print("Ring %d: Point check - distance=%.1f, bounds=[%.1f-%.1f], in_bounds=%s" % [
        ring_data.ring_index, distance, ring_data.inner_radius, ring_data.outer_radius, in_bounds
    ])

    return in_bounds
```

## Common Issues

### Issue 1: All Rings Show is_interactive=false
**Cause**: Initialization bug, all rings marked as locked
**Fix**: Check `puzzle_manager.gd` line 132-135 - only outermost ring should be locked

### Issue 2: No "GOT MOUSE EVENT" Prints
**Cause**: Input not reaching ring nodes at all
**Possible reasons**:
- Another UI element is blocking input (check z-index/order)
- Mouse filter set to IGNORE on ring nodes
- Ring nodes not visible or have size of (0, 0)

**Fix**: Check:
```gdscript
# In gameplay_screen.gd
rings_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Should pass through

# In spiral_ring_node.gd _ready()
mouse_filter = Control.MOUSE_FILTER_STOP  # Should capture input
```

### Issue 3: "Input ignored" Appears
**Cause**: Rings think they're locked
**Check**:
- Print `ring.is_locked` for all rings in `puzzle_manager._create_rings_from_image()`
- Should only be true for ring index == ring_count - 1

### Issue 4: Distance Check Fails
**Cause**: Ring node size doesn't match puzzle_radius
**Symptoms**: Click distance is outside ring bounds (e.g., distance=600, bounds=[0-450])
**Fix**: Ring nodes should have size equal to 2*puzzle_radius (900x900 for radius 450)

## Quick Test
Try clicking at the exact center of the puzzle area. This should be:
- **Inside** ring 0 (innermost, 0-150 radius)
- Print should show distance close to 0

Try clicking at the edge of the puzzle area. This should be:
- **Inside** ring 2 (outermost, 300-450 radius)
- Print should show distance close to 450

## Next Steps
1. Run the game with debug prints enabled
2. Click on different parts of the rings
3. Copy the console output
4. Share it so we can see exactly what's happening
