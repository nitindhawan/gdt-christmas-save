class_name Tile
extends Resource

## Individual puzzle tile

var tile_id: int = 0  # Unique identifier (0 to tile_count-1)
var current_position: Vector2i = Vector2i(0, 0)  # Current grid position (column, row)
var correct_position: Vector2i = Vector2i(0, 0)  # Solution position (column, row)
var texture_region: Rect2 = Rect2()  # Region of source image (x, y, width, height)

## Check if tile is in correct position
func is_correct() -> bool:
	return current_position == correct_position

## Swap positions with another tile
func swap_positions(other_tile: Tile) -> void:
	var temp_pos = current_position
	current_position = other_tile.current_position
	other_tile.current_position = temp_pos
