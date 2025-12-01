extends Control

## Level Complete Screen
## Displays completion message and completed image

var completed_level_id: int = 1
var completed_difficulty: int = GameConstants.Difficulty.EASY

# UI references
@onready var title_label = $MarginContainer/VBoxContainer/TitleSection/TitleLabel
@onready var subtitle_label = $MarginContainer/VBoxContainer/TitleSection/SubtitleLabel
@onready var continue_button = $MarginContainer/VBoxContainer/ButtonSection/ContinueButton
@onready var completed_image = $MarginContainer/VBoxContainer/ImageSection/ImagePanel/MarginContainer/CompletedImage

func _ready() -> void:
	# Apply theme
	_apply_theme()

	# Get level and difficulty from GameManager
	completed_level_id = GameManager.get_current_level()
	completed_difficulty = GameManager.get_current_difficulty()

	_initialize_screen()

func _apply_theme() -> void:
	# Apply font sizes from ThemeManager
	# title_label: 72 → 80 (XLARGE)
	# subtitle_label: 56 → 64 (LARGE)
	# continue_button: 64 (LARGE)
	ThemeManager.apply_xlarge(title_label, ThemeManager.COLOR_ACCENT)
	ThemeManager.apply_large(subtitle_label)
	ThemeManager.apply_large(continue_button)

## Initialize screen with level data
func _initialize_screen() -> void:
	# Update subtitle
	subtitle_label.text = "You solved Puzzle %d!" % completed_level_id

	# Load completed image
	var texture = LevelManager.get_level_texture(completed_level_id)
	if texture:
		completed_image.texture = texture
	else:
		push_warning("Failed to load completed image for puzzle %d" % completed_level_id)

	print("Level Complete screen initialized: Puzzle %d" % completed_level_id)

## Handle Continue button
func _on_continue_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Determine next action based on completion
	_navigate_next()

## Navigate to next screen
func _navigate_next() -> void:
	# Always go to next level
	var next_level = completed_level_id + 1

	# Cap at level 20
	if next_level > GameConstants.TOTAL_LEVELS:
		next_level = GameConstants.TOTAL_LEVELS

	# Navigate to gameplay (will show Choose Difficulty popup)
	print("Navigating to level: %d" % next_level)
	GameManager.navigate_to_gameplay_new_flow(next_level)

