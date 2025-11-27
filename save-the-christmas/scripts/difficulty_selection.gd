extends Control

## Difficulty Selection Screen
## Allows player to select Easy/Normal/Hard difficulty for a beaten level

var current_level_id: int = 1

# UI Node references
@onready var close_button = $MarginContainer/VBoxContainer/TopBar/CloseButton
@onready var share_button = $MarginContainer/VBoxContainer/TopBar/ShareButton
@onready var level_label = $MarginContainer/VBoxContainer/PreviewSection/LevelLabel
@onready var preview_image = $MarginContainer/VBoxContainer/PreviewSection/PreviewContainer/PreviewPanel/MarginContainer/PreviewImage
@onready var easy_button = $MarginContainer/VBoxContainer/DifficultyButtons/EasyButton
@onready var normal_button = $MarginContainer/VBoxContainer/DifficultyButtons/NormalButton
@onready var hard_button = $MarginContainer/VBoxContainer/DifficultyButtons/HardButton

func _ready():
	# Apply theme
	_apply_theme()

	# Get level ID from GameManager
	current_level_id = GameManager.get_current_level()
	initialize(current_level_id)

func _apply_theme() -> void:
	# Apply font sizes from ThemeManager
	# close_button: 72 → 80 (XLARGE)
	# share_button: 56 → 64 (LARGE)
	# level_label: 64 → 64 (LARGE) ✓
	# difficulty buttons: 56 → 64 (LARGE)
	ThemeManager.apply_xlarge(close_button)
	ThemeManager.apply_large(share_button)
	ThemeManager.apply_large(level_label)
	ThemeManager.apply_large(easy_button)
	ThemeManager.apply_large(normal_button)
	ThemeManager.apply_large(hard_button)

## Initialize the difficulty selection screen with a level ID
func initialize(level_id: int) -> void:
	current_level_id = level_id
	_load_level_data()
	_update_button_states()

## Load level preview image and set label
func _load_level_data() -> void:
	var level_data = LevelManager.get_level(current_level_id)
	if level_data == null:
		push_error("Failed to load level data for level %d" % current_level_id)
		return

	# Set level label
	level_label.text = "Level %d" % current_level_id

	# Load preview image
	var texture = LevelManager.get_level_texture(current_level_id)
	if texture:
		preview_image.texture = texture
	else:
		push_warning("Failed to load preview image for level %d" % current_level_id)

## Update button states based on unlock status
func _update_button_states() -> void:
	# Easy is always unlocked if level is unlocked
	var easy_unlocked = ProgressManager.is_difficulty_unlocked(current_level_id, "easy")
	easy_button.disabled = not easy_unlocked
	_apply_button_style(easy_button, easy_unlocked, ProgressManager.get_star(current_level_id, "easy"))

	# Normal unlocks after Easy completion
	var normal_unlocked = ProgressManager.is_difficulty_unlocked(current_level_id, "normal")
	normal_button.disabled = not normal_unlocked
	_apply_button_style(normal_button, normal_unlocked, ProgressManager.get_star(current_level_id, "normal"))

	# Hard unlocks after Normal completion
	var hard_unlocked = ProgressManager.is_difficulty_unlocked(current_level_id, "hard")
	hard_button.disabled = not hard_unlocked
	_apply_button_style(hard_button, hard_unlocked, ProgressManager.get_star(current_level_id, "hard"))

## Apply visual style to difficulty button based on state
func _apply_button_style(button: Button, is_unlocked: bool, has_star: bool) -> void:
	if is_unlocked:
		if has_star:
			# Gold tint if star earned
			button.modulate = Color(1.0, 0.843, 0.0, 0.3)  # Gold overlay
		else:
			# Green background for unlocked
			button.modulate = ThemeManager.COLOR_PRIMARY
	else:
		# Grey and semi-transparent if locked
		button.modulate = ThemeManager.COLOR_STATE_LOCKED

## Handle Close button - return to Level Selection
func _on_close_button_pressed() -> void:
	GameManager.navigate_to_level_selection()

## Handle Share button - share level preview
func _on_share_button_pressed() -> void:
	# TODO: Implement native share functionality
	# For MVP, this is a placeholder
	print("Share button pressed - native share not implemented yet")
	# Future: Share preview image with text "Check out this Christmas puzzle!"

## Handle Easy button - start level on Easy
func _on_easy_button_pressed() -> void:
	if not easy_button.disabled:
		GameManager.navigate_to_gameplay(current_level_id, GameConstants.Difficulty.EASY)

## Handle Normal button - start level on Normal
func _on_normal_button_pressed() -> void:
	if not normal_button.disabled:
		GameManager.navigate_to_gameplay(current_level_id, GameConstants.Difficulty.NORMAL)

## Handle Hard button - start level on Hard
func _on_hard_button_pressed() -> void:
	if not hard_button.disabled:
		GameManager.navigate_to_gameplay(current_level_id, GameConstants.Difficulty.HARD)
