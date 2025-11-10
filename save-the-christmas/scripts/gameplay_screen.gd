extends Control

## Gameplay Screen
## Main puzzle gameplay with tile swapping mechanics

const TILE_NODE_SCENE = preload("res://scenes/tile_node.tscn")
const SETTINGS_POPUP_SCENE = preload("res://scenes/settings_popup.tscn")

# Game state
var current_level_id: int = 1
var current_difficulty: int = GameConstants.Difficulty.EASY
var puzzle_state: PuzzleState
var tile_nodes: Array = []
var selected_tile_node = null
var source_texture: Texture2D

# UI references
@onready var level_label = $MarginContainer/VBoxContainer/TopHUD/MarginContainer/HBoxContainer/LevelLabel
@onready var puzzle_grid = $MarginContainer/VBoxContainer/PuzzleArea/PuzzleGrid
@onready var hint_button = $MarginContainer/VBoxContainer/BottomHUD/CenterContainer/HintButton
@onready var confirmation_dialog = $ConfirmationDialog

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

	# Setup puzzle grid
	_setup_puzzle_grid()

	# Spawn tiles
	_spawn_tiles()

	print("Gameplay initialized successfully")

## Setup puzzle grid layout based on difficulty
func _setup_puzzle_grid() -> void:
	var grid_size = puzzle_state.grid_size
	puzzle_grid.columns = grid_size.y  # columns

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
			tile_node.tile_clicked.connect(_on_tile_clicked)

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

## Handle tile clicked
func _on_tile_clicked(tile_node) -> void:
	print("Tile clicked: %d" % tile_node.tile_index)

	if selected_tile_node == null:
		# First selection
		selected_tile_node = tile_node
		tile_node.set_selected(true)
		print("Tile %d selected" % tile_node.tile_index)
	elif selected_tile_node == tile_node:
		# Clicked same tile - deselect
		selected_tile_node.set_selected(false)
		selected_tile_node = null
		print("Tile deselected")
	else:
		# Second selection - swap tiles
		var tile1_index = selected_tile_node.tile_index
		var tile2_index = tile_node.tile_index

		print("Swapping tiles %d and %d" % [tile1_index, tile2_index])

		# Deselect first
		selected_tile_node.set_selected(false)
		selected_tile_node = null

		# Swap in puzzle state
		PuzzleManager.swap_tiles(puzzle_state, tile1_index, tile2_index)

		# Refresh the entire grid to show new positions
		_refresh_tile_positions()

		# Check if puzzle solved
		await get_tree().create_timer(0.1).timeout
		_check_puzzle_solved()

## Check if puzzle is solved
func _check_puzzle_solved() -> void:
	if PuzzleManager.is_puzzle_solved(puzzle_state):
		print("Puzzle solved!")
		puzzle_state.is_solved = true

		# Play victory sound
		if AudioManager:
			AudioManager.play_sfx("level_complete")

		# Trigger haptic feedback
		if AudioManager:
			AudioManager.trigger_haptic(0.8)

		# Save progress
		_save_progress()

		# Navigate to level complete screen
		await get_tree().create_timer(1.0).timeout
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

	# Show confirmation dialog
	confirmation_dialog.popup_centered()

## Handle confirmation dialog confirmed (exit level)
func _on_confirmation_dialog_confirmed() -> void:
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
