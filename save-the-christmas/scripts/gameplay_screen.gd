extends Control

## Gameplay Screen
## Main puzzle gameplay with tile swapping mechanics

const TILE_NODE_SCENE = preload("res://scenes/tile_node.tscn")
const SPIRAL_RING_NODE_SCENE = preload("res://scenes/spiral_ring_node.tscn")
const SETTINGS_POPUP_SCENE = preload("res://scenes/settings_popup.tscn")
const EXIT_DIALOG_SCENE = preload("res://scenes/exit_confirmation_dialog.tscn")
const SpiralPuzzleState = preload("res://scripts/spiral_puzzle_state.gd")

# Game state
var current_level_id: int = 1
var current_difficulty: int = GameConstants.Difficulty.EASY
var puzzle_state: Resource # Can be PuzzleState or SpiralPuzzleState
var tile_nodes: Array = []
var ring_nodes: Array = []
var rings_container: Control = null # Container for spiral ring nodes
var source_texture: Texture2D
var is_spiral_puzzle: bool = false
var puzzle_center: Vector2 = Vector2(540, 960) # Center of 1080x1920 screen

# UI references
@onready var level_label = $MarginContainer/VBoxContainer/TopHUD/MarginContainer/HBoxContainer/LevelLabel
@onready var puzzle_grid = $MarginContainer/VBoxContainer/PuzzleArea/PuzzleGrid
@onready var hint_button = $MarginContainer/VBoxContainer/BottomHUD/CenterContainer/HintButton

func _ready() -> void:
	# Get level and difficulty from GameManager
	current_level_id = GameManager.get_current_level()
	current_difficulty = GameManager.get_current_difficulty()

	_initialize_gameplay()

## Initialize gameplay with current level and difficulty
func _initialize_gameplay() -> void:
	print("Initializing gameplay: Level %d, Difficulty %d" % [current_level_id, current_difficulty])

	# Update UI label
	var difficulty_str = GameConstants.difficulty_to_string(current_difficulty)
	level_label.text = "Level %d - %s" % [current_level_id, difficulty_str.capitalize()]

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

	if is_spiral_puzzle:
		# Setup spiral puzzle
		_setup_spiral_puzzle()
		await _spawn_spiral_rings()
	else:
		# Setup rectangle puzzle
		_setup_puzzle_grid()
		_spawn_tiles()

	print("Gameplay initialized successfully (%s puzzle)" % ("Spiral" if is_spiral_puzzle else "Rectangle"))

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

	# Set star for this level and difficulty
	ProgressManager.set_star(current_level_id, difficulty_str, true)

	# Unlock next level if completing Easy
	if current_difficulty == GameConstants.Difficulty.EASY:
		ProgressManager.unlock_next_level()

	# Update current level
	ProgressManager.current_level = current_level_id

	# Update statistics
	ProgressManager.total_swaps_made += puzzle_state.swap_count
	ProgressManager.total_hints_used += puzzle_state.hints_used

	# Save to disk
	ProgressManager.save_progress()

	print("Progress saved: Level %d, %s completed" % [current_level_id, difficulty_str])

## Handle hint button
func _on_hint_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Check hint limit
	var level_data = LevelManager.get_level(current_level_id)
	var hint_limit = level_data.get("hint_limit", GameConstants.DEFAULT_HINT_LIMIT)

	if puzzle_state.hints_used >= hint_limit:
		print("Hint limit reached")
		# TODO: Show message "No more hints available"
		return

	# Use hint
	var hinted_tile_index = PuzzleManager.use_hint(puzzle_state)
	if hinted_tile_index == -1:
		print("No hint needed - puzzle already solved")
		return

	# Play hint sound
	if AudioManager:
		AudioManager.play_sfx("hint_used")

	# Update hint button text
	hint_button.text = "💡 Hint (%d/%d)" % [puzzle_state.hints_used, hint_limit]

	# Refresh tile display (re-spawn to show new positions)
	_refresh_tile_positions()

	# Check if puzzle solved after hint
	await get_tree().create_timer(GameConstants.TILE_SWAP_DURATION + 0.1).timeout
	_check_puzzle_solved()

## Refresh tile positions without re-instantiating
func _refresh_tile_positions() -> void:
	# Clear current grid
	for child in puzzle_grid.get_children():
		child.queue_free()
	tile_nodes.clear()

	# Re-spawn tiles in new positions
	_spawn_tiles()

## Handle back button
func _on_back_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Show custom exit confirmation dialog
	var dialog = EXIT_DIALOG_SCENE.instantiate()
	dialog.exit_confirmed.connect(_on_exit_confirmed)
	add_child(dialog)

## Handle exit confirmed from dialog
func _on_exit_confirmed() -> void:
	GameManager.navigate_to_level_selection()

## Handle share button
func _on_share_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	print("Share button pressed")
	# TODO: Implement screenshot + native share
	# For MVP, placeholder

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

		# Set anchors to fill the container
		ring_node.set_anchors_preset(Control.PRESET_FULL_RECT)

		print("Added ring %d to container" % i)

		ring_nodes[i] = ring_node # Store in correct position

	print("Spawned %d spiral rings" % ring_nodes.size())

	# Wait for layout to complete
	await get_tree().process_frame
	print("Layout complete. Final puzzle area size: %v" % puzzle_area.size)

## Centralized input handler for all rings
var _dragging_ring_node: Control = null

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

	# Set star for this level and difficulty
	ProgressManager.set_star(current_level_id, difficulty_str, true)

	# Unlock next level if completing Easy
	if current_difficulty == GameConstants.Difficulty.EASY:
		ProgressManager.unlock_next_level()

	# Update current level
	ProgressManager.current_level = current_level_id

	# Update statistics
	ProgressManager.total_swaps_made += spiral_state.rotation_count
	ProgressManager.total_hints_used += spiral_state.hints_used

	# Save to disk
	ProgressManager.save_progress()

	print("Spiral progress saved: Level %d, %s completed" % [current_level_id, difficulty_str])
