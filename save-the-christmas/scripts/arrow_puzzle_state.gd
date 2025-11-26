class_name ArrowPuzzleState
extends Resource

## Arrow Puzzle State
## Manages the state of an arrow puzzle including movement and collision detection

const Arrow = preload("res://scripts/arrow.gd")

@export var level_id: int = 1
@export var difficulty: String = "easy"
@export var grid_size: Vector2i = Vector2i(5, 4)
@export var arrows: Array[Arrow] = []
@export var active_arrow_count: int = 0
@export var tap_count: int = 0
@export var direction_set: Array[int] = []  # Two allowed directions for this puzzle
@export var is_solved: bool = false


func is_puzzle_solved() -> bool:
	"""Check if puzzle is complete (all arrows have exited)"""
	return active_arrow_count == 0


func get_arrow_at_position(pos: Vector2i) -> Arrow:
	"""Find arrow at given grid coordinates, returns null if none found"""
	for arrow in arrows:
		if arrow.grid_position == pos and not arrow.has_exited:
			return arrow
	return null


func get_arrow_by_id(arrow_id: int) -> Arrow:
	"""Get arrow by its ID"""
	if arrow_id >= 0 and arrow_id < arrows.size():
		return arrows[arrow_id]
	return null


func is_position_blocked(pos: Vector2i, excluding_id: int = -1) -> bool:
	"""Check if a grid position is blocked by another arrow"""
	for arrow in arrows:
		if arrow.arrow_id != excluding_id and arrow.blocks_position(pos):
			return true
	return false


func is_position_out_of_bounds(pos: Vector2i) -> bool:
	"""Check if position is outside the grid boundaries"""
	return pos.x < 0 or pos.x >= grid_size.x or pos.y < 0 or pos.y >= grid_size.y


func attempt_arrow_movement(arrow_id: int) -> Dictionary:
	"""
	Attempt to move an arrow in its direction.
	Returns dictionary with:
	- success: bool (true if arrow can exit, false if blocked)
	- blocked_by: int (arrow_id that blocks, or -1 if not blocked)
	"""
	var arrow = get_arrow_by_id(arrow_id)

	# Validate arrow
	if arrow == null:
		push_error("Arrow not found: " + str(arrow_id))
		return {"success": false, "blocked_by": -1}

	if arrow.has_exited:
		return {"success": false, "blocked_by": -1}

	if arrow.is_animating:
		return {"success": false, "blocked_by": -1}

	# Get movement direction
	var dir_vector = arrow.get_direction_vector()
	var current_pos = arrow.grid_position

	# Trace path step by step
	var path_clear = true
	var blocked_by_id = -1

	while true:
		# Move one step in direction
		current_pos += dir_vector

		# Check if out of bounds (success - arrow can exit)
		if is_position_out_of_bounds(current_pos):
			path_clear = true
			break

		# Check if blocked by another arrow
		if is_position_blocked(current_pos, arrow_id):
			path_clear = false
			# Find which arrow is blocking
			for other_arrow in arrows:
				if other_arrow.arrow_id != arrow_id and other_arrow.blocks_position(current_pos):
					blocked_by_id = other_arrow.arrow_id
					break
			break

	return {
		"success": path_clear,
		"blocked_by": blocked_by_id
	}


func mark_arrow_exited(arrow_id: int) -> void:
	"""Mark an arrow as having exited the puzzle"""
	var arrow = get_arrow_by_id(arrow_id)
	if arrow != null and not arrow.has_exited:
		arrow.has_exited = true
		active_arrow_count -= 1

		# Check if puzzle is now solved
		if is_puzzle_solved():
			is_solved = true


func increment_tap_count() -> void:
	"""Increment the tap counter"""
	tap_count += 1


func get_direction_set_name() -> String:
	"""Returns a string describing the direction set (for debugging)"""
	if direction_set.size() != 2:
		return "INVALID"

	var dir1_name = _get_direction_name(direction_set[0])
	var dir2_name = _get_direction_name(direction_set[1])

	return dir1_name + " or " + dir2_name


func _get_direction_name(dir: int) -> String:
	"""Helper to convert direction int to name"""
	match dir:
		Arrow.Direction.UP:
			return "UP"
		Arrow.Direction.DOWN:
			return "DOWN"
		Arrow.Direction.LEFT:
			return "LEFT"
		Arrow.Direction.RIGHT:
			return "RIGHT"
		_:
			return "UNKNOWN"
