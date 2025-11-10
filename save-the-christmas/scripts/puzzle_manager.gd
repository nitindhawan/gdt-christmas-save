extends Node

## Puzzle Manager AutoLoad Singleton
## Handles puzzle generation, tile creation, and scrambling

## Generate a puzzle state from level data and difficulty
func generate_puzzle(level_id: int, difficulty: int) -> PuzzleState:
	var level_data = LevelManager.get_level(level_id)
	if level_data.is_empty():
		push_error("Failed to get level data for level %d" % level_id)
		return null

	# Get difficulty configuration
	var difficulty_str = GameConstants.difficulty_to_string(difficulty)
	var diff_config = level_data["difficulty_configs"][difficulty_str]

	if diff_config == null:
		push_error("No difficulty config found for %s" % difficulty_str)
		return null

	var rows = diff_config["rows"]
	var columns = diff_config["columns"]
	var tile_count = diff_config["tile_count"]

	# Load level image
	var texture = LevelManager.get_level_texture(level_id)
	if texture == null:
		push_error("Failed to load level image for level %d" % level_id)
		return null

	# Create puzzle state
	var puzzle_state = PuzzleState.new()
	puzzle_state.level_id = level_id
	puzzle_state.difficulty = GameConstants.difficulty_to_string(difficulty)
	puzzle_state.grid_size = Vector2i(rows, columns)
	puzzle_state.tiles = create_tiles_from_image(texture, rows, columns)
	puzzle_state.selected_tile_index = -1
	puzzle_state.swap_count = 0
	puzzle_state.hints_used = 0
	puzzle_state.is_solved = false

	# Scramble tiles
	scramble_tiles(puzzle_state)

	print("Generated puzzle: Level %d, %s, Grid %dx%d, Tiles: %d" % [level_id, difficulty_str, rows, columns, puzzle_state.tiles.size()])

	return puzzle_state

## Create tiles from an image divided into a grid
func create_tiles_from_image(texture: Texture2D, rows: int, columns: int) -> Array[Tile]:
	var tiles: Array[Tile] = []

	var image_size = texture.get_size()
	var tile_width = image_size.x / columns
	var tile_height = image_size.y / rows

	var tile_id = 0
	for row in range(rows):
		for col in range(columns):
			var tile = Tile.new()
			tile.tile_id = tile_id
			tile.correct_position = Vector2i(row, col)
			tile.current_position = Vector2i(row, col)  # Start in correct position

			# Define texture region for this tile
			var region_x = col * tile_width
			var region_y = row * tile_height
			tile.texture_region = Rect2(region_x, region_y, tile_width, tile_height)

			tiles.append(tile)
			tile_id += 1

	return tiles

## Scramble tiles using Fisher-Yates shuffle
func scramble_tiles(puzzle_state: PuzzleState) -> void:
	var tiles = puzzle_state.tiles
	var n = tiles.size()

	# Fisher-Yates shuffle
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)

		# Swap current positions
		var temp_pos = tiles[i].current_position
		tiles[i].current_position = tiles[j].current_position
		tiles[j].current_position = temp_pos

	# Verify puzzle is not already solved
	var attempts = 0
	while is_puzzle_solved(puzzle_state) and attempts < 10:
		# Shuffle again if already solved
		for i in range(n - 1, 0, -1):
			var j = randi() % (i + 1)
			var temp_pos = tiles[i].current_position
			tiles[i].current_position = tiles[j].current_position
			tiles[j].current_position = temp_pos
		attempts += 1

	print("Puzzle scrambled (attempts: %d)" % (attempts + 1))

## Check if puzzle is solved (all tiles in correct positions)
func is_puzzle_solved(puzzle_state: PuzzleState) -> bool:
	for tile in puzzle_state.tiles:
		if tile.current_position != tile.correct_position:
			return false
	return true

## Swap two tiles in the puzzle
func swap_tiles(puzzle_state: PuzzleState, tile1_index: int, tile2_index: int) -> void:
	if tile1_index < 0 or tile1_index >= puzzle_state.tiles.size():
		push_error("Invalid tile1 index: %d" % tile1_index)
		return
	if tile2_index < 0 or tile2_index >= puzzle_state.tiles.size():
		push_error("Invalid tile2 index: %d" % tile2_index)
		return

	var tile1 = puzzle_state.tiles[tile1_index]
	var tile2 = puzzle_state.tiles[tile2_index]

	# Swap current positions
	var temp_pos = tile1.current_position
	tile1.current_position = tile2.current_position
	tile2.current_position = temp_pos

	puzzle_state.swap_count += 1
	print("Swapped tiles %d and %d (total swaps: %d)" % [tile1_index, tile2_index, puzzle_state.swap_count])

## Use a hint - move one incorrect tile to correct position
func use_hint(puzzle_state: PuzzleState) -> int:
	# Find first incorrect tile
	var incorrect_tile_index = -1
	for i in range(puzzle_state.tiles.size()):
		if not puzzle_state.tiles[i].is_correct():
			incorrect_tile_index = i
			break

	if incorrect_tile_index == -1:
		print("No incorrect tiles found - puzzle already solved!")
		return -1

	# Find the tile currently at the correct position
	var incorrect_tile = puzzle_state.tiles[incorrect_tile_index]
	var target_position = incorrect_tile.correct_position

	var tile_at_correct_position_index = -1
	for i in range(puzzle_state.tiles.size()):
		if puzzle_state.tiles[i].current_position == target_position:
			tile_at_correct_position_index = i
			break

	if tile_at_correct_position_index == -1:
		push_error("Could not find tile at target position")
		return -1

	# Swap the tiles
	swap_tiles(puzzle_state, incorrect_tile_index, tile_at_correct_position_index)
	puzzle_state.hints_used += 1

	print("Hint used: Moved tile %d to correct position (hints used: %d)" % [incorrect_tile_index, puzzle_state.hints_used])

	return incorrect_tile_index

## Get tile index by grid position
func get_tile_index_at_position(puzzle_state: PuzzleState, position: Vector2i) -> int:
	for i in range(puzzle_state.tiles.size()):
		if puzzle_state.tiles[i].current_position == position:
			return i
	return -1
