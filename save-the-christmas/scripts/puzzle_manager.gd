extends Node

## Puzzle Manager AutoLoad Singleton
## Handles puzzle generation, tile creation, and scrambling

const SpiralRing = preload("res://scripts/spiral_ring.gd")
const SpiralPuzzleState = preload("res://scripts/spiral_puzzle_state.gd")

## Generate a puzzle state from level data and difficulty
func generate_puzzle(level_id: int, difficulty: int) -> Resource:
	var level_data = LevelManager.get_level(level_id)
	if level_data.is_empty():
		push_error("Failed to get level data for level %d" % level_id)
		return null

	# Determine puzzle type
	var puzzle_type = level_data.get("puzzle_type", "rectangle_jigsaw")

	# Route to appropriate generation method
	if puzzle_type == "spiral_twist":
		return _generate_spiral_puzzle(level_id, difficulty, level_data)
	else:
		return _generate_rectangle_puzzle(level_id, difficulty, level_data)

## Generate a rectangle jigsaw puzzle (original implementation)
func _generate_rectangle_puzzle(level_id: int, difficulty: int, level_data: Dictionary) -> PuzzleState:
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

	print("Generated rectangle puzzle: Level %d, %s, Grid %dx%d, Tiles: %d" % [level_id, difficulty_str, rows, columns, puzzle_state.tiles.size()])

	return puzzle_state

## Generate a spiral twist puzzle
func _generate_spiral_puzzle(level_id: int, difficulty: int, level_data: Dictionary) -> SpiralPuzzleState:
	var difficulty_str = GameConstants.difficulty_to_string(difficulty)
	var diff_config = level_data["difficulty_configs"][difficulty_str]

	if diff_config == null:
		push_error("No difficulty config found for %s" % difficulty_str)
		return null

	# Get ring count from difficulty config or use defaults
	var ring_count = diff_config.get("ring_count", _get_default_ring_count(difficulty))

	# Load level image
	var texture = LevelManager.get_level_texture(level_id)
	if texture == null:
		push_error("Failed to load level image for level %d" % level_id)
		return null

	# Create spiral puzzle state
	var puzzle_state = SpiralPuzzleState.new()
	puzzle_state.level_id = level_id
	puzzle_state.difficulty = difficulty_str
	puzzle_state.ring_count = ring_count
	puzzle_state.rotation_count = 0
	puzzle_state.hints_used = 0
	puzzle_state.is_solved = false

	# Create rings from image
	puzzle_state.rings = _create_rings_from_image(texture, ring_count, puzzle_state.puzzle_radius)
	puzzle_state.active_ring_count = ring_count

	# Scramble rings (randomize rotations)
	_scramble_rings(puzzle_state)

	print("Generated spiral puzzle: Level %d, %s, Rings: %d" % [level_id, difficulty_str, ring_count])

	return puzzle_state

## Get default ring count based on difficulty
func _get_default_ring_count(difficulty: int) -> int:
	match difficulty:
		GameConstants.Difficulty.EASY:
			return GameConstants.SPIRAL_RINGS_EASY
		GameConstants.Difficulty.NORMAL:
			return GameConstants.SPIRAL_RINGS_NORMAL
		GameConstants.Difficulty.HARD:
			return GameConstants.SPIRAL_RINGS_HARD
		_:
			return GameConstants.SPIRAL_RINGS_EASY

## Create rings from circular image
func _create_rings_from_image(texture: Texture2D, ring_count: int, max_radius: float) -> Array[SpiralRing]:
	var rings: Array[SpiralRing] = []

	# Calculate ring width (equal bands)
	var ring_width = max_radius / ring_count

	for i in range(ring_count):
		var ring = SpiralRing.new()
		ring.ring_index = i
		ring.correct_angle = 0.0  # All rings start at 0 degrees when correct
		ring.current_angle = 0.0  # Will be randomized in scramble
		ring.angular_velocity = 0.0
		ring.inner_radius = i * ring_width
		ring.outer_radius = (i + 1) * ring_width

		# Outermost ring is static (merged from start)
		if i == ring_count - 1:
			ring.is_merged = true
			ring.current_angle = 0.0
			ring.angular_velocity = 0.0

		rings.append(ring)

	return rings

## Scramble rings by randomizing their rotations
func _scramble_rings(puzzle_state: SpiralPuzzleState) -> void:
	# Randomize rotation for all non-merged rings
	for ring in puzzle_state.rings:
		if not ring.is_merged:
			# Random angle between -180 and 180 degrees
			ring.current_angle = randf_range(-180.0, 180.0)
			ring.angular_velocity = 0.0

	# Ensure puzzle is not already solved
	var attempts = 0
	while puzzle_state.is_puzzle_solved() and attempts < 10:
		for ring in puzzle_state.rings:
			if not ring.is_merged:
				ring.current_angle = randf_range(-180.0, 180.0)
		attempts += 1

	print("Spiral puzzle scrambled (attempts: %d)" % (attempts + 1))

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
