extends Control

## Level Selection Screen
## Displays grid of level thumbnails with stars and handles navigation

const LEVEL_CELL_SCENE = preload("res://scenes/level_cell.tscn")
const SETTINGS_POPUP_SCENE = preload("res://scenes/settings_popup.tscn")

@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleBar/Title

func _ready() -> void:
	# Apply theme
	_apply_theme()

	_populate_level_grid()

func _apply_theme() -> void:
	# Apply font sizes from ThemeManager
	# Title: 60 → 64 (LARGE)
	ThemeManager.apply_large(title_label)

## Populate grid with level cells
func _populate_level_grid() -> void:
	# Clear existing cells
	for child in grid_container.get_children():
		child.queue_free()

	# Get total levels from LevelManager
	var total_levels = LevelManager.get_total_levels()

	# Create a cell for each level
	for level_id in range(1, total_levels + 1):
		var level_cell = LEVEL_CELL_SCENE.instantiate()
		grid_container.add_child(level_cell)

		# Get level data
		var level_data = LevelManager.get_level(level_id)
		if level_data.is_empty():
			push_error("Failed to get level data for level " + str(level_id))
			continue

		# Load thumbnail
		var thumbnail = LevelManager.get_thumbnail_texture(level_id)

		# Check if level is unlocked
		var is_unlocked = ProgressManager.is_level_unlocked(level_id)

		# Get star count
		var star_count = ProgressManager.get_star_count(level_id)

		# Check if beaten (has at least one star)
		var is_beaten = star_count > 0

		# Setup level cell
		level_cell.setup(level_id, thumbnail, star_count, is_unlocked, is_beaten)

		# Connect signal
		level_cell.level_clicked.connect(_on_level_clicked)

## Handle level cell clicked
func _on_level_clicked(level_id: int) -> void:
	print("Level ", level_id, " clicked")

	# Check if level has been beaten (has stars)
	var star_count = ProgressManager.get_star_count(level_id)
	var is_beaten = star_count > 0

	if is_beaten:
		# Navigate to Difficulty Selection
		GameManager.navigate_to_difficulty_selection(level_id)
	else:
		# Navigate directly to Gameplay (Easy mode)
		GameManager.navigate_to_gameplay(level_id, GameConstants.Difficulty.EASY)

## Handle settings button pressed
func _on_settings_button_pressed() -> void:
	print("Settings button pressed")

	# Play button click sound
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Instantiate and show settings popup
	var settings_popup = SETTINGS_POPUP_SCENE.instantiate()
	add_child(settings_popup)

	# Connect close signal to handle cleanup (optional)
	settings_popup.settings_closed.connect(_on_settings_popup_closed)

## Handle settings popup closed
func _on_settings_popup_closed() -> void:
	print("Settings popup closed")
