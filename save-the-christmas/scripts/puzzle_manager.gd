extends Node

## Puzzle Manager AutoLoad Singleton
## Handles puzzle generation, tile creation, and scrambling

const SpiralRing = preload("res://scripts/spiral_ring.gd")
const SpiralPuzzleState = preload("res://scripts/spiral_puzzle_state.gd")
const ArrowPuzzleState = preload("res://scripts/arrow_puzzle_state.gd")
const Arrow = preload("res://scripts/arrow.gd")
const RowTilePuzzleState = preload("res://scripts/row_tile_puzzle_state.gd")
const RowTile = preload("res://scripts/row_tile.gd")

## Generate a puzzle state from level data and difficulty
func generate_puzzle(level_id: int, difficulty: int) -> Resource:
	var level_data = LevelManager.get_level(level_id)
	if level_data.is_empty():
		push_error("Failed to get level data for level %d" % level_id)
		return null

	# Determine puzzle type
	var puzzle_type = level_data.get("puzzle_type", "tile_puzzle")

	# Route to appropriate generation method
	if puzzle_type == "spiral_twist":
		return _generate_spiral_puzzle(level_id, difficulty, level_data)
	elif puzzle_type == "arrow_puzzle":
		return _generate_arrow_puzzle(level_id, difficulty, level_data)
	elif puzzle_type == "row_tile_puzzle":
		return _generate_row_tile_puzzle(level_id, difficulty, level_data)
	else:
		return _generate_tile_puzzle(level_id, difficulty, level_data)

## Generate a tile puzzle (original implementation)
func _generate_tile_puzzle(level_id: int, difficulty: int, level_data: Dictionary) -> PuzzleState:
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

	# Get actual viewport dimensions from GameConstants (set during loading)
	var available_width = GameConstants.get_available_width()
	var available_height = GameConstants.get_available_height()

	print("PuzzleManager: Using available area %.1fx%.1f for tile region calculation" % [available_width, available_height])

	# Create puzzle state
	var puzzle_state = PuzzleState.new()
	puzzle_state.level_id = level_id
	puzzle_state.difficulty = GameConstants.difficulty_to_string(difficulty)
	puzzle_state.grid_size = Vector2i(rows, columns)
	puzzle_state.tiles = create_tiles_from_image(texture, rows, columns, available_width, available_height)
	puzzle_state.selected_tile_index = -1
	puzzle_state.swap_count = 0
	puzzle_state.hints_used = 0
	puzzle_state.is_solved = false

	# Scramble tiles
	scramble_tiles(puzzle_state)

	print("Generated tile puzzle: Level %d, %s, Grid %dx%d, Tiles: %d" % [level_id, difficulty_str, rows, columns, puzzle_state.tiles.size()])

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

	# max_radius will be set dynamically by gameplay_screen based on available height
	# For now, use a default that will be overwritten
	var max_radius = 512.0
	puzzle_state.puzzle_radius = max_radius

	print("Spiral puzzle: initial max_radius=%.1f (will be updated dynamically)" % max_radius)

	# Create rings from image (includes corner ring)
	# Note: Rings will be regenerated in gameplay_screen with actual max_radius
	puzzle_state.rings = _create_rings_from_image(texture, ring_count, max_radius)

	# Count non-merged rings (excludes corner ring which is always locked)
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
		GameConstants.Difficulty.HARD:
			return GameConstants.SPIRAL_RINGS_HARD
		_:
			return GameConstants.SPIRAL_RINGS_EASY

## Create rings from circular image
func _create_rings_from_image(texture: Texture2D, ring_count: int, max_radius: float) -> Array[SpiralRing]:
	var rings: Array[SpiralRing] = []

	# Calculate ring widths: central ring is 3x larger than normal rings
	# Formula: max_radius = central_ring_width + (ring_count - 1) * normal_ring_width
	# Where: central_ring_width = 3 * normal_ring_width
	# So: max_radius = 3 * normal_ring_width + (ring_count - 1) * normal_ring_width
	#     max_radius = (ring_count + 2) * normal_ring_width
	var normal_ring_width = max_radius / (ring_count + 2)
	var central_ring_width = normal_ring_width * 3

	print("Creating %d rings with max_radius=%.1f, normal_ring_width=%.1f, central_ring_width=%.1f" % [
		ring_count, max_radius, normal_ring_width, central_ring_width
	])

	for i in range(ring_count):
		var ring = SpiralRing.new()
		ring.ring_index = i
		ring.correct_angle = 0.0  # All rings start at 0 degrees when correct
		ring.current_angle = 0.0  # Will be randomized in scramble
		ring.angular_velocity = 0.0

		# Calculate inner/outer radii based on position
		if i == 0:
			# Central ring (3x larger)
			ring.inner_radius = 0.0
			ring.outer_radius = central_ring_width
		else:
			# Outer rings (normal width)
			ring.inner_radius = central_ring_width + (i - 1) * normal_ring_width
			ring.outer_radius = central_ring_width + i * normal_ring_width

		print("  Ring %d: inner_radius=%.1f, outer_radius=%.1f, is_locked=%s" % [
			i, ring.inner_radius, ring.outer_radius, str(ring.is_locked)
		])

		rings.append(ring)

	# Create special corner ring (static, shows rectangular corners)
	var corner_ring = SpiralRing.new()
	corner_ring.ring_index = ring_count  # After all puzzle rings
	corner_ring.correct_angle = 0.0
	corner_ring.current_angle = 0.0
	corner_ring.angular_velocity = 0.0
	corner_ring.inner_radius = max_radius  # Starts where puzzle ends
	corner_ring.outer_radius = max_radius * sqrt(2.0)  # Half of square diagonal
	corner_ring.is_locked = true  # Fixed, immovable

	print("  Corner ring: inner_radius=%.1f, outer_radius=%.1f, is_locked=true" % [
		corner_ring.inner_radius, corner_ring.outer_radius
	])

	rings.append(corner_ring)

	return rings

## Scramble rings by randomizing their rotations
func _scramble_rings(puzzle_state: SpiralPuzzleState) -> void:
	# Randomize rotation for all non-locked rings
	for ring in puzzle_state.rings:
		if not ring.is_locked:
			# Random angle between -180 and 180 degrees, but not too close to 0
			var angle = randf_range(-180.0, 180.0)
			# Ensure angle is at least 20 degrees away from correct position
			while abs(angle) < 20.0:
				angle = randf_range(-180.0, 180.0)
			ring.current_angle = angle
			ring.angular_velocity = 0.0

	# Verify at least one ring is significantly misaligned
	var max_angle_diff = 0.0
	for ring in puzzle_state.rings:
		if not ring.is_locked:
			max_angle_diff = max(max_angle_diff, abs(ring.current_angle))

	# If all rings are too close to correct, re-scramble
	var attempts = 0
	while max_angle_diff < 20.0 and attempts < 10:
		for ring in puzzle_state.rings:
			if not ring.is_locked:
				ring.current_angle = randf_range(-180.0, 180.0)

		max_angle_diff = 0.0
		for ring in puzzle_state.rings:
			if not ring.is_locked:
				max_angle_diff = max(max_angle_diff, abs(ring.current_angle))
		attempts += 1

	print("Spiral puzzle scrambled (attempts: %d, max angle: %.1f)" % [attempts + 1, max_angle_diff])

## Generate an arrow puzzle
func _generate_arrow_puzzle(level_id: int, difficulty: int, level_data: Dictionary) -> ArrowPuzzleState:
	var difficulty_str = GameConstants.difficulty_to_string(difficulty)
	var diff_config = level_data["difficulty_configs"][difficulty_str]

	if diff_config == null:
		push_error("No difficulty config found for %s" % difficulty_str)
		return null

	# Get grid size from difficulty config or use defaults
	var grid_size: Vector2i
	if diff_config.has("grid_size"):
		# JSON stores as dictionary with x and y
		if diff_config["grid_size"] is Dictionary:
			grid_size = Vector2i(
				diff_config["grid_size"].get("x", 5),
				diff_config["grid_size"].get("y", 4)
			)
		else:
			grid_size = diff_config["grid_size"]
	else:
		grid_size = _get_default_arrow_grid_size(difficulty)

	# Load level texture (for background rendering)
	var texture = LevelManager.get_level_texture(level_id)
	if texture == null:
		push_error("Failed to load level image for level %d" % level_id)
		return null

	# Create arrow puzzle state
	var puzzle_state = ArrowPuzzleState.new()
	puzzle_state.level_id = level_id
	puzzle_state.difficulty = difficulty_str
	puzzle_state.grid_size = grid_size
	puzzle_state.tap_count = 0
	puzzle_state.is_solved = false

	# Pick a random direction set (one of 4 pairs)
	var direction_sets = [
		[Arrow.Direction.LEFT, Arrow.Direction.UP],
		[Arrow.Direction.LEFT, Arrow.Direction.DOWN],
		[Arrow.Direction.RIGHT, Arrow.Direction.UP],
		[Arrow.Direction.RIGHT, Arrow.Direction.DOWN]
	]
	var selected_set = direction_sets[randi() % 4]

	# Create properly typed array
	var typed_direction_set: Array[int] = []
	typed_direction_set.append(selected_set[0])
	typed_direction_set.append(selected_set[1])
	puzzle_state.direction_set = typed_direction_set

	# Create arrows for the grid
	puzzle_state.arrows = _create_arrows_for_grid(grid_size, puzzle_state.direction_set)
	puzzle_state.active_arrow_count = puzzle_state.arrows.size()

	print("Generated arrow puzzle: Level %d, %s, Grid %dx%d, Arrows: %d, Directions: %s" % [
		level_id, difficulty_str, grid_size.x, grid_size.y,
		puzzle_state.arrows.size(), puzzle_state.get_direction_set_name()
	])

	return puzzle_state

## Get default arrow grid size based on difficulty
func _get_default_arrow_grid_size(difficulty: int) -> Vector2i:
	match difficulty:
		GameConstants.Difficulty.EASY:
			return GameConstants.ARROW_GRID_EASY
		GameConstants.Difficulty.HARD:
			return GameConstants.ARROW_GRID_HARD
		_:
			return GameConstants.ARROW_GRID_EASY

## Create arrows for a grid with specified direction set
func _create_arrows_for_grid(grid_size: Vector2i, direction_set: Array[int]) -> Array[Arrow]:
	var arrows: Array[Arrow] = []
	var arrow_id = 0

	for row in range(grid_size.y):
		for col in range(grid_size.x):
			var arrow = Arrow.new()
			arrow.arrow_id = arrow_id
			arrow.grid_position = Vector2i(col, row)
			# Randomly pick one of the two allowed directions
			arrow.direction = direction_set[randi() % 2]
			arrow.has_exited = false
			arrow.is_animating = false

			arrows.append(arrow)
			arrow_id += 1

	return arrows

## Generate a row tile puzzle
func _generate_row_tile_puzzle(level_id: int, difficulty: int, level_data: Dictionary) -> RowTilePuzzleState:
	var difficulty_str = GameConstants.difficulty_to_string(difficulty)
	var diff_config = level_data["difficulty_configs"][difficulty_str]

	if diff_config == null:
		push_error("No difficulty config found for %s" % difficulty_str)
		return null

	# Get row count from difficulty config or use defaults
	var row_count = diff_config.get("row_count", _get_default_row_count(difficulty))

	# Load level texture
	var texture = LevelManager.get_level_texture(level_id)
	if texture == null:
		push_error("Failed to load level image for level %d" % level_id)
		return null

	# Create row tile puzzle state
	var puzzle_state = RowTilePuzzleState.new()
	puzzle_state.level_id = level_id
	puzzle_state.difficulty = difficulty_str
	puzzle_state.row_count = row_count
	puzzle_state.swap_count = 0
	puzzle_state.is_solved = false

	# Create rows from image
	puzzle_state.rows = _create_rows_from_image(texture, row_count)

	# Scramble rows
	_scramble_rows(puzzle_state)

	print("Generated row tile puzzle: Level %d, %s, Rows: %d" % [level_id, difficulty_str, row_count])

	return puzzle_state

## Get default row count based on difficulty
func _get_default_row_count(difficulty: int) -> int:
	match difficulty:
		GameConstants.Difficulty.EASY:
			return GameConstants.ROW_TILE_ROWS_EASY
		GameConstants.Difficulty.HARD:
			return GameConstants.ROW_TILE_ROWS_HARD
		_:
			return GameConstants.ROW_TILE_ROWS_EASY

## Create rows from an image divided into horizontal strips
func _create_rows_from_image(texture: Texture2D, row_count: int) -> Array[RowTile]:
	var rows: Array[RowTile] = []

	var image_size = texture.get_size()
	var row_height = image_size.y / row_count

	for i in range(row_count):
		var row = RowTile.new()
		row.row_id = i
		row.correct_position = i
		row.current_position = i  # Start in correct position

		# Define texture region for this row (full width, portion of height)
		var region_y = i * row_height
		row.texture_region = Rect2(0, region_y, image_size.x, row_height)

		rows.append(row)

	return rows

## Scramble rows using Fisher-Yates shuffle
func _scramble_rows(puzzle_state: RowTilePuzzleState) -> void:
	var rows = puzzle_state.rows
	var n = rows.size()

	# Fisher-Yates shuffle
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)

		# Swap current positions
		var temp_pos = rows[i].current_position
		rows[i].current_position = rows[j].current_position
		rows[j].current_position = temp_pos

	# Verify puzzle is not already solved
	var attempts = 0
	while _is_row_puzzle_solved(puzzle_state) and attempts < 10:
		# Shuffle again if already solved
		for i in range(n - 1, 0, -1):
			var j = randi() % (i + 1)
			var temp_pos = rows[i].current_position
			rows[i].current_position = rows[j].current_position
			rows[j].current_position = temp_pos
		attempts += 1

	print("Row puzzle scrambled (attempts: %d)" % (attempts + 1))

## Check if row puzzle is solved (all rows in correct positions)
func _is_row_puzzle_solved(puzzle_state: RowTilePuzzleState) -> bool:
	for row in puzzle_state.rows:
		if row.current_position != row.correct_position:
			return false
	return true

## Create tiles from an image divided into a grid
func create_tiles_from_image(texture: Texture2D, rows: int, columns: int, available_width: float = 0.0, available_height: float = 0.0) -> Array[Tile]:
	var tiles: Array[Tile] = []

	# Get texture dimensions
	var texture_width = texture.get_size().x
	var texture_height = texture.get_size().y

	# If available dimensions not provided, use texture dimensions (no clipping)
	if available_width <= 0.0:
		available_width = texture_width
	if available_height <= 0.0:
		available_height = texture_height

	# Calculate zoom factor (based on height fitting)
	var zoom_factor = available_height / texture_height

	# Calculate zoomed texture dimensions
	var zoomed_texture_width = texture_width * zoom_factor
	var zoomed_texture_height = texture_height * zoom_factor  # This equals available_height

	# Calculate how much gets clipped horizontally (in screen coordinates)
	var horizontal_clip_screen = (zoomed_texture_width - available_width) / 2.0

	# Convert clip amount back to texture coordinates
	var horizontal_clip_texture = horizontal_clip_screen / zoom_factor

	# Calculate visible texture region (in original texture coordinates)
	var visible_texture_x_start = horizontal_clip_texture
	var visible_texture_x_end = texture_width - horizontal_clip_texture
	var visible_texture_width = visible_texture_x_end - visible_texture_x_start

	var visible_texture_y_start = 0.0
	var visible_texture_y_end = texture_height
	var visible_texture_height = visible_texture_y_end - visible_texture_y_start

	print("=== TILE TEXTURE REGION CALCULATION ===")
	print("Texture size: %.1f x %.1f" % [texture_width, texture_height])
	print("Available area: %.1f x %.1f" % [available_width, available_height])
	print("Zoom factor: %.3f" % zoom_factor)
	print("Zoomed texture: %.1f x %.1f" % [zoomed_texture_width, zoomed_texture_height])
	print("Horizontal clip (screen): %.1f" % horizontal_clip_screen)
	print("Horizontal clip (texture): %.1f" % horizontal_clip_texture)
	print("Visible texture region: (%.1f, %.1f) to (%.1f, %.1f)" % [
		visible_texture_x_start, visible_texture_y_start,
		visible_texture_x_end, visible_texture_y_end
	])
	print("Visible texture size: %.1f x %.1f" % [visible_texture_width, visible_texture_height])

	# Calculate tile size from visible portion
	var tile_texture_width = visible_texture_width / columns
	var tile_texture_height = visible_texture_height / rows

	print("Tile texture size: %.1f x %.1f" % [tile_texture_width, tile_texture_height])

	# Create tiles from visible texture region only
	var tile_id = 0
	print("\n--- Creating Tiles ---")
	for row in range(rows):
		for col in range(columns):
			var tile = Tile.new()
			tile.tile_id = tile_id
			tile.correct_position = Vector2i(row, col)
			tile.current_position = Vector2i(row, col)  # Start in correct position

			# Define texture region for this tile (from visible portion)
			var region_x = visible_texture_x_start + (col * tile_texture_width)
			var region_y = visible_texture_y_start + (row * tile_texture_height)
			tile.texture_region = Rect2(region_x, region_y, tile_texture_width, tile_texture_height)

			print("  Tile[%d] at (%d,%d): region=(%.1f, %.1f, %.1f, %.1f)" % [
				tile_id, row, col,
				tile.texture_region.position.x, tile.texture_region.position.y,
				tile.texture_region.size.x, tile.texture_region.size.y
			])

			tiles.append(tile)
			tile_id += 1

	print("Created %d tiles" % tiles.size())
	print("=======================================")

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

## Get tile index by grid position
func get_tile_index_at_position(puzzle_state: PuzzleState, position: Vector2i) -> int:
	for i in range(puzzle_state.tiles.size()):
		if puzzle_state.tiles[i].current_position == position:
			return i
	return -1
