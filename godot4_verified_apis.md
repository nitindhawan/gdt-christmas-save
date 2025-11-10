# Godot 4.4.1 Verified APIs

## Verified Safe APIs
### Enums
- ✅ **Enum Declaration**: Standard enum syntax works correctly
  ```gdscript
  enum RingColor {
      EMPTY = 0,
      RED = 1,
      GREEN = 2
  }
  ```
- ✅ **Global Enum Access**: Can access enums from autoloaded singletons
  ```gdscript
  GameConstants.RingColor.RED
  GameConstants.RingSize.BIG
  ```

### Type Annotations
- ✅ **Function Parameters**: Enum types in function signatures work
  ```gdscript
  func place_ring(color: GameConstants.RingColor, size: GameConstants.RingSize) -> bool:
  ```
- ✅ **Type Casting**: Enum casting works with full enum paths
  ```gdscript
  ring_size as GameConstants.RingSize
  ```

## APIs to Avoid
### Type System Features
- ❌ **typedef/Type Aliases**: NOT SUPPORTED in Godot 4.4.1
  ```gdscript
  # BROKEN - This syntax does not work
  typedef RingColor = GameConstants.RingColor
  typedef RingSize = GameConstants.RingSize
  ```
  - **Error**: "Unexpected identifier 'typedefRingColor' in class body"
  - **Workaround**: Use full enum paths directly

## Uncertain APIs
(Require verification before use)

## Migration Notes
### Type System Limitations
- **No Type Aliasing**: Unlike languages like Rust, Go, or C++, GDScript 4.4.1 does not support type aliases
- **Active Proposal**: GitHub issue #11503 requests this feature for future versions
- **Enum Typing**: Named enums cannot be used as explicit types in all typed contexts (known limitation)

## Usage Examples
### Correct Enum Usage
```gdscript
# ✅ CORRECT - Direct enum access
var color: int = GameConstants.RingColor.RED
if rings[i] == GameConstants.RingColor.EMPTY:
    return true

# ✅ CORRECT - Enum in function parameters
func place_ring(color: GameConstants.RingColor, size: GameConstants.RingSize) -> bool:
    rings[size] = color
    return true
```

### Incorrect Type Alias Usage
```gdscript
# ❌ BROKEN - typedef not supported
typedef RingColor = GameConstants.RingColor
var color: RingColor = RingColor.RED  # This will fail

# ✅ WORKAROUND - Use full path
var color: int = GameConstants.RingColor.RED
```
