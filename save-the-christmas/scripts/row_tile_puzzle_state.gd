class_name RowTilePuzzleState
extends Resource

## Row Tile Puzzle State - Horizontal rows that can be swapped

var level_id: int = 0
var difficulty: String = "easy"
var row_count: int = 8  # Number of horizontal rows
var rows: Array = []  # Array of RowTile objects
var selected_row_index: int = -1  # Currently selected row (-1 if none)
var swap_count: int = 0  # Number of swaps made
var hints_used: int = 0  # Hints used (deprecated, kept for compatibility)
var is_solved: bool = false

## Check if all rows are in correct positions
func is_puzzle_solved() -> bool:
	for row in rows:
		if row != null and row.has_method("is_correct"):
			if not row.is_correct():
				return false
	return true

## Get row at a specific index
func get_row_at_index(index: int) -> Resource:
	if index >= 0 and index < rows.size():
		return rows[index]
	return null

## Swap two rows by their indices
func swap_rows(index1: int, index2: int) -> void:
	if index1 < 0 or index1 >= rows.size():
		return
	if index2 < 0 or index2 >= rows.size():
		return

	var row1 = rows[index1]
	var row2 = rows[index2]

	if row1 != null and row2 != null:
		# Swap current positions
		var temp_pos = row1.current_position
		row1.current_position = row2.current_position
		row2.current_position = temp_pos

		swap_count += 1

## Reset selected row
func clear_selection() -> void:
	selected_row_index = -1
