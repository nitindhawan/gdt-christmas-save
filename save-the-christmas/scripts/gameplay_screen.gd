extends Control

## Gameplay Screen
## Main puzzle gameplay with tile swapping mechanics

const TILE_NODE_SCENE = preload("res://scenes/tile_node.tscn")
const SPIRAL_RING_NODE_SCENE = preload("res://scenes/spiral_ring_node.tscn")
const ARROW_NODE_SCENE = preload("res://scenes/arrow_node.tscn")
const SETTINGS_POPUP_SCENE = preload("res://scenes/settings_popup.tscn")
const EXIT_DIALOG_SCENE = preload("res://scenes/exit_confirmation_dialog.tscn")
const CHOOSE_DIFFICULTY_POPUP_SCENE = preload("res://scenes/choose_difficulty_popup.tscn")
const GRINCH_TRANSITION_SCENE = preload("res://scenes/grinch_transition.tscn")
const SpiralPuzzleState = preload("res://scripts/spiral_puzzle_state.gd")
const ArrowPuzzleState = preload("res://scripts/arrow_puzzle_state.gd")

# Gameplay state machine
enum GameplayState {
	CHOOSE_DIFFICULTY,
	GRINCH_TRANSITION,
	INITIALIZING_PUZZLE,
	ACTIVE_PUZZLE,
	PUZZLE_COMPLETE
}

# Game state
var current_state: GameplayState = GameplayState.CHOOSE_DIFFICULTY
var current_level_id: int = 1
var current_difficulty: int = GameConstants.Difficulty.EASY
var puzzle_state: Resource # Can be PuzzleState, SpiralPuzzleState, or ArrowPuzzleState
var tile_nodes: Array = []
var ring_nodes: Array = []
var arrow_nodes: Array = []
var rings_container: Control = null # Container for spiral ring nodes
var arrows_container: Control = null # Container for arrow nodes
var background_image: TextureRect = null # Background image for arrow puzzle
var source_texture: Texture2D
var is_spiral_puzzle: bool = false
var is_arrow_puzzle: bool = false
var puzzle_center: Vector2 = Vector2(540, 960) # Center of 1080x1920 screen

# UI references
@onready var level_label = $MarginContainer/VBoxContainer/TopHUD/LevelLabel
@onready var puzzle_grid = $MarginContainer/VBoxContainer/PuzzleArea/PuzzleGrid
@onready var settings_button = $MarginContainer/VBoxContainer/TopHUD/SettingsButton

func _ready() -> void:
	# Apply theme
	_apply_theme()

	# Get level from GameManager
	current_level_id = GameManager.get_current_level()

	# Set level label immediately so it shows during difficulty popup
	level_label.text = "Puzzle %d" % current_level_id

	# Start with difficulty selection
	current_state = GameplayState.CHOOSE_DIFFICULTY
	_show_difficulty_popup()

func _apply_theme() -> void:
	# Apply font sizes from ThemeManager
	# level_label: MEDIUM (32px)
	ThemeManager.apply_medium(level_label)

## Show difficulty selection popup
func _show_difficulty_popup() -> void:
	print("Showing difficulty popup")
	var popup = CHOOSE_DIFFICULTY_POPUP_SCENE.instantiate()
	popup.difficulty_chosen.connect(_on_difficulty_chosen)
	add_child(popup)

## Handle difficulty selection
func _on_difficulty_chosen(difficulty: int) -> void:
	print("Difficulty chosen: ", difficulty)
	current_difficulty = difficulty
	GameManager.current_difficulty = difficulty

	current_state = GameplayState.GRINCH_TRANSITION
	_start_grinch_transition()

## Start grinch transition animation
func _start_grinch_transition() -> void:
	print("Starting grinch transition")

	# Load level texture
	source_texture = LevelManager.get_level_texture(current_level_id)
	if source_texture == null:
		push_error("Failed to load level texture for level %d" % current_level_id)
		return

	# Create and setup transition
	var transition = GRINCH_TRANSITION_SCENE.instantiate()
	transition.set_level_texture(source_texture)
	transition.transition_complete.connect(_on_transition_complete)
	add_child(transition)
	transition.play_transition()

## Handle transition complete
func _on_transition_complete() -> void:
	print("Transition complete, initializing puzzle")
	current_state = GameplayState.INITIALIZING_PUZZLE
	_initialize_gameplay()
	current_state = GameplayState.ACTIVE_PUZZLE

## Initialize gameplay with current level and difficulty
func _initialize_gameplay() -> void:
	print("Initializing gameplay: Level %d, Difficulty %d" % [current_level_id, current_difficulty])

	# Load source texture
	source_texture = LevelManager.get_level_texture(current_level_id)
	if source_texture == null:
		push_error("Failed to load level image for level %d" % current_level_id)
		return

	# Generate puzzle
	puzzle_state = PuzzleManager.generate_puzzle(current_level_id, current_difficulty)
	if puzzle_state == null:
		push_error("Failed to generate puzzle")
		return

	# Determine puzzle type
	is_spiral_puzzle = puzzle_state is SpiralPuzzleState
	is_arrow_puzzle = puzzle_state is ArrowPuzzleState

	if is_spiral_puzzle:
		# Setup spiral puzzle
		_setup_spiral_puzzle()
		await _spawn_spiral_rings()
	elif is_arrow_puzzle:
		# Setup arrow puzzle
		_setup_arrow_puzzle()
		_spawn_arrows()
	else:
		# Setup rectangle puzzle
		_setup_puzzle_grid()
		_spawn_tiles()

	var puzzle_type_name = "Spiral" if is_spiral_puzzle else ("Arrow" if is_arrow_puzzle else "Rectangle")
	print("Gameplay initialized successfully (%s puzzle)" % puzzle_type_name)

## Setup puzzle grid layout based on difficulty
func _setup_puzzle_grid() -> void:
	var grid_size = puzzle_state.grid_size
	puzzle_grid.columns = grid_size.y # columns

	print("Grid configured: %d rows x %d columns" % [grid_size.x, grid_size.y])

## Spawn tile nodes in the grid
func _spawn_tiles() -> void:
	# Clear existing tiles
	for child in puzzle_grid.get_children():
		child.queue_free()
	tile_nodes.clear()

	# Calculate tile size based on difficulty and available space
	var tile_size = _calculate_tile_size()

	# Create tile nodes in grid order (by current position)
	# We need to place tiles based on their current position
	var grid_size = puzzle_state.grid_size
	for row in range(grid_size.x):
		for col in range(grid_size.y):
			var position = Vector2i(row, col)
			var tile_index = PuzzleManager.get_tile_index_at_position(puzzle_state, position)

			if tile_index == -1:
				push_error("No tile found at position %v" % position)
				continue

			var tile = puzzle_state.tiles[tile_index]
			var tile_node = TILE_NODE_SCENE.instantiate()
			tile_node.custom_minimum_size = tile_size

			# Add to tree first so @onready variables are initialized
			puzzle_grid.add_child(tile_node)

			# Now setup the tile
			tile_node.setup(tile, tile_index, source_texture)
			tile_node.drag_ended.connect(_on_tile_drag_ended)

			tile_nodes.append(tile_node)

	print("Spawned %d tiles" % tile_nodes.size())

## Calculate appropriate tile size based on difficulty
func _calculate_tile_size() -> Vector2:
	var grid_size = puzzle_state.grid_size
	var rows = grid_size.x
	var columns = grid_size.y

	# Get the actual image size to maintain aspect ratio
	var image_size = source_texture.get_size()
	var image_aspect = image_size.x / image_size.y

	# Calculate tile dimensions based on image aspect ratio
	var tile_width_from_image = image_size.x / columns
	var tile_height_from_image = image_size.y / rows

	# Available space (approximate, accounting for margins and HUD)
	var available_width = 900.0
	var available_height = 1500.0

	# Calculate maximum size that fits while maintaining aspect ratio
	var max_width = available_width / columns
	var max_height = available_height / rows

	# Use the limiting dimension
	var scale_by_width = max_width / tile_width_from_image
	var scale_by_height = max_height / tile_height_from_image
	var scale = min(scale_by_width, scale_by_height)

	# Calculate final tile size maintaining image aspect ratio
	var tile_width = tile_width_from_image * scale
	var tile_height = tile_height_from_image * scale

	return Vector2(tile_width, tile_height)

## Handle tile drag ended (swap if dropped on another tile)
func _on_tile_drag_ended(dragged_tile_node, target_tile_node) -> void:
	if target_tile_node == null:
		# Dropped on empty space - snap back
		print("Tile %d dropped on empty space" % dragged_tile_node.tile_index)
		_refresh_tile_positions()
		return

	# Get the tile indices
	var tile1_index = dragged_tile_node.tile_index
	var tile2_index = target_tile_node.tile_index

	print("Swapping tiles %d and %d" % [tile1_index, tile2_index])

	# Swap in puzzle state
	PuzzleManager.swap_tiles(puzzle_state, tile1_index, tile2_index)

	# Play swap sound
	if AudioManager:
		AudioManager.play_sfx("tile_swap")

	# Refresh the entire grid to show new positions and update draggable status
	_refresh_tile_positions()

	# Check if puzzle solved
	await get_tree().create_timer(0.1).timeout
	_check_puzzle_solved()

## Check if puzzle is solved
func _check_puzzle_solved() -> void:
	if PuzzleManager.is_puzzle_solved(puzzle_state):
		print("Rectangle puzzle solved!")
		puzzle_state.is_solved = true
		_save_progress()
		await _handle_puzzle_completion()

## Unified puzzle completion handler
## Plays victory effects, delays for player feedback, then navigates to completion screen
## This method provides a centralized place to integrate SFX and VFX effects
func _handle_puzzle_completion() -> void:
	# Play victory sound
	if AudioManager:
		AudioManager.play_sfx("level_complete")

	# Trigger haptic feedback
	if AudioManager:
		AudioManager.trigger_haptic(0.8)

	# TODO: Add confetti VFX here

	# Delay to let player see completed puzzle and effects
	await get_tree().create_timer(2.5).timeout

	# Navigate to level complete screen
	GameManager.navigate_to_level_complete()

## Save progress after completing level
func _save_progress() -> void:
	var difficulty_str = GameConstants.difficulty_to_string(current_difficulty)

	# Mark as completed (replaces set_star)
	ProgressManager.set_completion(current_level_id, difficulty_str, true)

	# Unlock next level if completing Easy
	if current_difficulty == GameConstants.Difficulty.EASY:
		ProgressManager.unlock_next_level()

	# Update current level tracker
	if current_level_id == ProgressManager.current_level:
		var next_level = mini(current_level_id + 1, GameConstants.TOTAL_LEVELS)
		ProgressManager.current_level = next_level

	# Update statistics
	ProgressManager.total_swaps_made += puzzle_state.swap_count
	ProgressManager.total_hints_used += puzzle_state.hints_used

	# Save to disk
	ProgressManager.save_progress()

	print("Progress saved: Level %d, %s completed" % [current_level_id, difficulty_str])

## Refresh tile positions without re-instantiating
func _refresh_tile_positions() -> void:
	# Clear current grid
	for child in puzzle_grid.get_children():
		child.queue_free()
	tile_nodes.clear()

	# Re-spawn tiles in new positions
	_spawn_tiles()


## Handle settings button
func _on_settings_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Instantiate and show settings popup
	var settings_popup = SETTINGS_POPUP_SCENE.instantiate()
	add_child(settings_popup)

## ============================================================================
## SPIRAL PUZZLE METHODS
## ============================================================================

## Physics update for spiral puzzles
func _process(delta: float) -> void:
	if not is_spiral_puzzle or puzzle_state == null:
		return

	var spiral_state = puzzle_state as SpiralPuzzleState

	# Update ring physics
	spiral_state.update_physics(delta)

	# Check for merges
	if spiral_state.check_and_merge_rings():
		print("Rings merged! Active rings: %d" % spiral_state.active_ring_count)

		# Play merge sound
		if AudioManager:
			AudioManager.play_sfx("ring_merge")

		_refresh_spiral_visuals()

		# Regenerate meshes for remaining rings (inner_radius may have changed)
		for ring_node in ring_nodes:
			if ring_node != null:
				ring_node.regenerate_mesh()

		# Check if puzzle solved
		if spiral_state.is_puzzle_solved():
			_check_spiral_puzzle_solved()

	# Update visual display
	_update_spiral_ring_visuals()

## Setup spiral puzzle container
func _setup_spiral_puzzle() -> void:
	# Hide rectangle grid
	puzzle_grid.visible = false

	# Get puzzle area control
	var puzzle_area = $MarginContainer/VBoxContainer/PuzzleArea

	# Set minimum size for puzzle area to ensure it has dimensions
	puzzle_area.custom_minimum_size = Vector2(900, 900)
	puzzle_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	print("Spiral puzzle configured: %d rings" % puzzle_state.ring_count)

## Spawn spiral ring nodes
func _spawn_spiral_rings() -> void:
	# Clear existing rings
	for ring_node in ring_nodes:
		ring_node.queue_free()
	ring_nodes.clear()

	var spiral_state = puzzle_state as SpiralPuzzleState

	# Get puzzle area control
	var puzzle_area = $MarginContainer/VBoxContainer/PuzzleArea

	# Force update layout
	puzzle_area.reset_size()
	await get_tree().process_frame

	print("Puzzle area size after layout: %v" % puzzle_area.size)

	# If still no size, set it manually
	if puzzle_area.size.x == 0 or puzzle_area.size.y == 0:
		puzzle_area.size = Vector2(900, 900)
		print("Forced puzzle area size to: %v" % puzzle_area.size)

	# Create a Control container for rings that handles ALL input
	rings_container = Control.new()
	rings_container.name = "RingsContainer"
	rings_container.custom_minimum_size = puzzle_area.size
	rings_container.mouse_filter = Control.MOUSE_FILTER_STOP # Capture all input here
	puzzle_area.add_child(rings_container)

	# Connect input handling to this container
	rings_container.gui_input.connect(_on_rings_container_input)

	await get_tree().process_frame
	print("Rings container size: %v, position: %v" % [rings_container.size, rings_container.position])

	# Pre-allocate array to correct size
	ring_nodes.resize(spiral_state.rings.size())

	# Create ring nodes (spawn from outermost to innermost so inner rings are on top)
	for i in range(spiral_state.rings.size() - 1, -1, -1):
		var ring = spiral_state.rings[i]
		var ring_node = SPIRAL_RING_NODE_SCENE.instantiate()

		# Setup ring node BEFORE adding to tree
		ring_node.ring_data = ring
		ring_node.source_texture = source_texture

		# Debug: Print ring initialization
		print("Ring %d: is_locked=%s, radii=%.1f-%.1f" % [
			i, ring.is_locked, ring.inner_radius, ring.outer_radius
		])

		# Add to rings container
		rings_container.add_child(ring_node)

		# MeshInstance2D uses position, not anchors
		# Center the ring at the container's center
		ring_node.position = rings_container.size / 2.0

		print("Added ring %d to container" % i)

		ring_nodes[i] = ring_node # Store in correct position

	print("Spawned %d spiral rings" % ring_nodes.size())

	# Wait for layout to complete
	await get_tree().process_frame
	print("Layout complete. Final puzzle area size: %v" % puzzle_area.size)

## Centralized input handler for all rings
var _dragging_ring_node: MeshInstance2D = null

func _on_rings_container_input(event: InputEvent) -> void:
	if not is_spiral_puzzle:
		return

	var spiral_state = puzzle_state as SpiralPuzzleState
	var event_pos: Vector2

	if event is InputEventMouseButton:
		event_pos = event.position
	elif event is InputEventMouseMotion:
		event_pos = event.position
	else:
		return

	# Calculate distance from center
	if rings_container == null:
		return
	var center = rings_container.size / 2.0
	var offset = event_pos - center
	var distance = offset.length()

	# Handle mouse button press/release
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Find which ring was clicked (check from innermost to outermost)
				for i in range(spiral_state.rings.size()):
					var ring = spiral_state.rings[i]
					if ring.is_locked:
						continue
					if distance >= ring.inner_radius and distance <= ring.outer_radius:
						# Found the clicked ring
						_dragging_ring_node = ring_nodes[i]
						_dragging_ring_node.start_drag_external(event_pos)
						print("Started dragging Ring %d at distance %.1f" % [i, distance])
						break
			else:
				# Release
				if _dragging_ring_node != null:
					var angular_velocity = _dragging_ring_node.end_drag_external()
					var ring_data = _dragging_ring_node.ring_data
					var ring_index = spiral_state.rings.find(ring_data)
					if ring_index >= 0:
						spiral_state.set_ring_velocity(ring_index, angular_velocity)
					if AudioManager:
						AudioManager.play_sfx("tile_drop")
					_dragging_ring_node = null

	# Handle mouse motion during drag
	elif event is InputEventMouseMotion:
		if _dragging_ring_node != null:
			var angle_delta = _dragging_ring_node.update_drag_external(event_pos)
			var ring_data = _dragging_ring_node.ring_data
			var ring_index = spiral_state.rings.find(ring_data)
			if ring_index >= 0:
				spiral_state.rotate_ring(ring_index, angle_delta)

## Update ring visual rotations
func _update_spiral_ring_visuals() -> void:
	for i in range(ring_nodes.size()):
		if i < ring_nodes.size() and ring_nodes[i] != null:
			ring_nodes[i].update_visual()

## Refresh spiral visuals after merge
func _refresh_spiral_visuals() -> void:
	var spiral_state = puzzle_state as SpiralPuzzleState

	# Handle ring removal: rings array has shrunk, need to sync ring_nodes
	# If a ring was removed, hide/remove the corresponding node
	while ring_nodes.size() > spiral_state.rings.size():
		var removed_index = ring_nodes.size() - 1
		var removed_node = ring_nodes[removed_index]
		if removed_node != null:
			removed_node.queue_free()
		ring_nodes.remove_at(removed_index)

	# Update remaining ring nodes to match current ring data
	for i in range(ring_nodes.size()):
		if i < spiral_state.rings.size():
			var ring = spiral_state.rings[i]
			var ring_node = ring_nodes[i]
			ring_node.ring_data = ring # Update to current ring data (may have expanded)
			ring_node.update_visual()

## Check if spiral puzzle is solved
func _check_spiral_puzzle_solved() -> void:
	var spiral_state = puzzle_state as SpiralPuzzleState

	if spiral_state.is_puzzle_solved():
		print("Spiral puzzle solved!")
		spiral_state.is_solved = true
		_save_spiral_progress()

		await _handle_puzzle_completion()

## Save progress for spiral puzzle
func _save_spiral_progress() -> void:
	var spiral_state = puzzle_state as SpiralPuzzleState
	var difficulty_str = GameConstants.difficulty_to_string(current_difficulty)

	# Mark as completed (replaces set_star)
	ProgressManager.set_completion(current_level_id, difficulty_str, true)

	# Unlock next level if completing Easy
	if current_difficulty == GameConstants.Difficulty.EASY:
		ProgressManager.unlock_next_level()

	# Update current level tracker
	if current_level_id == ProgressManager.current_level:
		var next_level = mini(current_level_id + 1, GameConstants.TOTAL_LEVELS)
		ProgressManager.current_level = next_level

	# Update statistics
	ProgressManager.total_swaps_made += spiral_state.rotation_count
	ProgressManager.total_hints_used += spiral_state.hints_used

	# Save to disk
	ProgressManager.save_progress()

	print("Spiral progress saved: Level %d, %s completed" % [current_level_id, difficulty_str])

## ============================================================================
## ARROW PUZZLE METHODS
## ============================================================================

## Setup arrow puzzle with background image and arrows container
func _setup_arrow_puzzle() -> void:
	# Hide rectangle grid
	puzzle_grid.visible = false

	# Get puzzle area control
	var puzzle_area = $MarginContainer/VBoxContainer/PuzzleArea

	# Don't force a fixed size - let it expand naturally
	# PuzzleArea already has size_flags_vertical = 3 to expand and fill available space

	var arrow_state = puzzle_state as ArrowPuzzleState
	print("Arrow puzzle configured: %dx%d grid = %d arrows" % [
		arrow_state.grid_size.x, arrow_state.grid_size.y, arrow_state.arrows.size()
	])

## Spawn arrow nodes in a grid layout
func _spawn_arrows() -> void:
	# Clear existing arrows
	for arrow_node in arrow_nodes:
		arrow_node.queue_free()
	arrow_nodes.clear()

	var arrow_state = puzzle_state as ArrowPuzzleState

	# Get puzzle area control
	var puzzle_area = $MarginContainer/VBoxContainer/PuzzleArea

	# Wait for layout to complete so puzzle_area has its actual size
	await get_tree().process_frame

	# Determine available size for puzzle (square aspect)
	var available_width = puzzle_area.size.x
	var available_height = puzzle_area.size.y
	var puzzle_size = min(available_width, available_height)

	# Create background image (full level image visible)
	background_image = TextureRect.new()
	background_image.name = "BackgroundImage"
	background_image.texture = source_texture
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	background_image.custom_minimum_size = Vector2(puzzle_size, puzzle_size)
	background_image.size = Vector2(puzzle_size, puzzle_size)
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	puzzle_area.add_child(background_image)

	# Create arrows container (overlay on top of background)
	arrows_container = Control.new()
	arrows_container.name = "ArrowsContainer"
	arrows_container.custom_minimum_size = Vector2(puzzle_size, puzzle_size)
	arrows_container.size = Vector2(puzzle_size, puzzle_size)
	arrows_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	puzzle_area.add_child(arrows_container)

	await get_tree().process_frame

	# Calculate arrow size and spacing
	var arrow_size = _calculate_arrow_size(arrow_state.grid_size)
	var grid_width = arrow_state.grid_size.x * arrow_size.x + (arrow_state.grid_size.x - 1) * GameConstants.ARROW_GRID_SPACING
	var grid_height = arrow_state.grid_size.y * arrow_size.y + (arrow_state.grid_size.y - 1) * GameConstants.ARROW_GRID_SPACING

	# Center the grid in the puzzle area
	var start_x = (arrows_container.size.x - grid_width) / 2.0
	var start_y = (arrows_container.size.y - grid_height) / 2.0

	# Create arrow nodes
	arrow_nodes.resize(arrow_state.arrows.size())

	for arrow in arrow_state.arrows:
		var arrow_node = ARROW_NODE_SCENE.instantiate()
		arrow_node.custom_minimum_size = arrow_size

		# Position in grid
		var pos_x = start_x + arrow.grid_position.x * (arrow_size.x + GameConstants.ARROW_GRID_SPACING)
		var pos_y = start_y + arrow.grid_position.y * (arrow_size.y + GameConstants.ARROW_GRID_SPACING)
		arrow_node.position = Vector2(pos_x, pos_y)
		arrow_node.size = arrow_size

		arrows_container.add_child(arrow_node)

		# Setup arrow (loads texture and sets rotation)
		arrow_node.setup(arrow)

		# Connect signal
		arrow_node.arrow_tapped.connect(_on_arrow_tapped)

		arrow_nodes[arrow.arrow_id] = arrow_node

	print("Spawned %d arrows in %dx%d grid" % [arrow_nodes.size(), arrow_state.grid_size.x, arrow_state.grid_size.y])

## Calculate arrow size based on grid dimensions
func _calculate_arrow_size(grid_size: Vector2i) -> Vector2:
	# Use arrows_container size (which is the actual puzzle area size)
	var available_width = arrows_container.size.x - 40 # Margins
	var available_height = arrows_container.size.y - 40

	# Calculate size based on grid
	var arrow_width = (available_width - (grid_size.x - 1) * GameConstants.ARROW_GRID_SPACING) / grid_size.x
	var arrow_height = (available_height - (grid_size.y - 1) * GameConstants.ARROW_GRID_SPACING) / grid_size.y

	# Use the smaller dimension to keep arrows square
	var arrow_size = min(arrow_width, arrow_height)
	arrow_size = min(arrow_size, 120.0) # Max size cap

	return Vector2(arrow_size, arrow_size)

## Handle arrow tap
func _on_arrow_tapped(arrow_id: int) -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	var arrow_state = puzzle_state as ArrowPuzzleState

	# Increment tap count
	arrow_state.increment_tap_count()

	# Attempt arrow movement
	var result = arrow_state.attempt_arrow_movement(arrow_id)

	var arrow_node = arrow_nodes[arrow_id]

	if result.success:
		# Arrow can exit - animate and remove
		arrow_state.mark_arrow_exited(arrow_id)
		arrow_node.animate_exit()
		await arrow_node.tree_exited

		# Check if puzzle solved
		if arrow_state.is_puzzle_solved():
			_check_arrow_puzzle_solved()
	else:
		# Arrow is blocked - bounce back
		arrow_node.animate_bounce()
		if AudioManager:
			AudioManager.play_sfx("error")

## Check if arrow puzzle is solved
func _check_arrow_puzzle_solved() -> void:
	var arrow_state = puzzle_state as ArrowPuzzleState

	if arrow_state.is_puzzle_solved():
		print("Arrow puzzle solved!")
		arrow_state.is_solved = true
		_save_arrow_progress()

		await _handle_puzzle_completion()

## Save progress for arrow puzzle
func _save_arrow_progress() -> void:
	var arrow_state = puzzle_state as ArrowPuzzleState
	var difficulty_str = GameConstants.difficulty_to_string(current_difficulty)

	# Mark as completed (replaces set_star)
	ProgressManager.set_completion(current_level_id, difficulty_str, true)

	# Unlock next level if completing Easy
	if current_difficulty == GameConstants.Difficulty.EASY:
		ProgressManager.unlock_next_level()

	# Update current level tracker
	if current_level_id == ProgressManager.current_level:
		var next_level = mini(current_level_id + 1, GameConstants.TOTAL_LEVELS)
		ProgressManager.current_level = next_level

	# Update statistics
	ProgressManager.total_swaps_made += arrow_state.tap_count

	# Save to disk
	ProgressManager.save_progress()

	print("Arrow progress saved: Level %d, %s completed" % [current_level_id, difficulty_str])
