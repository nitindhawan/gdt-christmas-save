extends Control

## Level Complete Screen
## Displays completion message, stars earned, and completed image

var completed_level_id: int = 1
var completed_difficulty: int = GameConstants.Difficulty.EASY

# UI references
@onready var subtitle_label = $MarginContainer/VBoxContainer/TitleSection/SubtitleLabel
@onready var completed_image = $MarginContainer/VBoxContainer/ImageSection/ImagePanel/MarginContainer/CompletedImage

func _ready() -> void:
	# Get level and difficulty from GameManager
	completed_level_id = GameManager.get_current_level()
	completed_difficulty = GameManager.get_current_difficulty()

	_initialize_screen()

## Initialize screen with level data
func _initialize_screen() -> void:
	# Update subtitle
	subtitle_label.text = "You solved Level %d!" % completed_level_id

	# Load completed image
	var texture = LevelManager.get_level_texture(completed_level_id)
	if texture:
		completed_image.texture = texture
	else:
		push_warning("Failed to load completed image for level %d" % completed_level_id)

	print("Level Complete screen initialized: Level %d" % completed_level_id)

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

## Handle Share button
func _on_share_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	print("Share button pressed")
	# TODO: Implement native share functionality
	# - Take screenshot or use completed image
	# - Open native share sheet with text: "I solved this Christmas puzzle!"
	# For MVP, placeholder

## Handle Download button
func _on_download_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	print("Download button pressed")
	# TODO: Implement save to gallery
	# - Requires platform-specific permissions
	# - Save completed image to device photo library
	# For MVP, placeholder
