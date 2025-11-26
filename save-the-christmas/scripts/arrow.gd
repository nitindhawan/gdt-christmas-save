class_name Arrow
extends Resource

## Arrow element for Arrow Puzzle
## Represents a single arrow on the puzzle grid with direction and state

enum Direction {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3
}

@export var arrow_id: int = 0
@export var grid_position: Vector2i = Vector2i(0, 0)
@export var direction: Direction = Direction.UP
@export var has_exited: bool = false
@export var is_animating: bool = false


func get_rotation_degrees() -> float:
	"""Returns the rotation angle in degrees for rendering the arrow"""
	match direction:
		Direction.UP:
			return 0.0
		Direction.RIGHT:
			return 90.0
		Direction.DOWN:
			return 180.0
		Direction.LEFT:
			return 270.0
		_:
			return 0.0


func get_direction_vector() -> Vector2i:
	"""Returns the movement vector for this arrow's direction"""
	match direction:
		Direction.UP:
			return Vector2i(0, -1)
		Direction.DOWN:
			return Vector2i(0, 1)
		Direction.LEFT:
			return Vector2i(-1, 0)
		Direction.RIGHT:
			return Vector2i(1, 0)
		_:
			return Vector2i(0, 0)


func blocks_position(check_pos: Vector2i) -> bool:
	"""Check if this arrow blocks a given grid position"""
	return not has_exited and grid_position == check_pos


func get_direction_name() -> String:
	"""Returns the direction name as a string (for debugging)"""
	match direction:
		Direction.UP:
			return "UP"
		Direction.DOWN:
			return "DOWN"
		Direction.LEFT:
			return "LEFT"
		Direction.RIGHT:
			return "RIGHT"
		_:
			return "UNKNOWN"
