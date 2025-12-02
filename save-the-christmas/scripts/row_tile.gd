class_name RowTile
extends Resource

## Row Tile - A horizontal strip of the image

var row_id: int = 0  # Unique identifier
var current_position: int = 0  # Current row index (0 = top)
var correct_position: int = 0  # Correct row index
var texture_region: Rect2 = Rect2()  # Region of the source image

## Check if row is in the correct position
func is_correct() -> bool:
	return current_position == correct_position
