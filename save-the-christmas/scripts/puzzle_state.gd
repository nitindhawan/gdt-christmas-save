class_name PuzzleState
extends Resource

## Current puzzle gameplay state

var level_id: int = 0
var difficulty: String = "easy"
var grid_size: Vector2i = Vector2i(3, 2)  # (columns, rows)
var tiles: Array = []  # Array of Tile objects
var selected_tile_index: int = -1  # Currently selected tile (-1 if none)
var swap_count: int = 0  # Number of swaps made
var hints_used: int = 0  # Hints used this session
var is_solved: bool = false

## Check if all tiles are in correct positions
func is_puzzle_solved() -> bool:
	for tile in tiles:
		if tile != null and tile.has_method("is_correct"):
			if not tile.is_correct():
				return false
	return true

## Get tile at a specific grid position
func get_tile_at_position(position: Vector2i) -> Resource:
	for tile in tiles:
		if tile != null and tile.has("current_position"):
			if tile.current_position == position:
				return tile
	return null

## Get tile by index
func get_tile_by_index(index: int) -> Resource:
	if index >= 0 and index < tiles.size():
		return tiles[index]
	return null

## Swap two tiles by their indices
func swap_tiles(index1: int, index2: int) -> void:
	if index1 < 0 or index1 >= tiles.size():
		return
	if index2 < 0 or index2 >= tiles.size():
		return

	var tile1 = tiles[index1]
	var tile2 = tiles[index2]

	if tile1 != null and tile2 != null:
		if tile1.has_method("swap_positions") and tile2.has_method("swap_positions"):
			# Swap positions in Tile objects
			var temp_pos = tile1.current_position
			tile1.current_position = tile2.current_position
			tile2.current_position = temp_pos

			# Swap in array
			tiles[index1] = tile2
			tiles[index2] = tile1

			swap_count += 1

## Reset selected tile
func clear_selection() -> void:
	selected_tile_index = -1
