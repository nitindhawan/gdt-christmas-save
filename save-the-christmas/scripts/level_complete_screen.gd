extends Control

## Level Complete Screen
## Displays completion message, stars earned, and completed image

var completed_level_id: int = 1
var completed_difficulty: int = GameConstants.Difficulty.EASY
var stars_earned: int = 1

# UI references
@onready var subtitle_label = $MarginContainer/VBoxContainer/TitleSection/SubtitleLabel
@onready var star1 = $MarginContainer/VBoxContainer/TitleSection/StarsContainer/Star1
@onready var star2 = $MarginContainer/VBoxContainer/TitleSection/StarsContainer/Star2
@onready var star3 = $MarginContainer/VBoxContainer/TitleSection/StarsContainer/Star3
@onready var completed_image = $MarginContainer/VBoxContainer/ImageSection/ImagePanel/MarginContainer/CompletedImage

func _ready() -> void:
	# Get level and difficulty from GameManager
	completed_level_id = GameManager.get_current_level()
	completed_difficulty = GameManager.get_current_difficulty()

	_initialize_screen()
	_animate_stars()

## Initialize screen with level data
func _initialize_screen() -> void:
	# Update subtitle
	subtitle_label.text = "You have solved Level %d" % completed_level_id

	# Determine stars earned based on difficulty
	match completed_difficulty:
		GameConstants.Difficulty.EASY:
			stars_earned = 1
		GameConstants.Difficulty.NORMAL:
			stars_earned = 2
		GameConstants.Difficulty.HARD:
			stars_earned = 3
		_:
			stars_earned = 1

	# Load completed image
	var texture = LevelManager.get_level_texture(completed_level_id)
	if texture:
		completed_image.texture = texture
	else:
		push_warning("Failed to load completed image for level %d" % completed_level_id)

	# Hide all stars initially (will be animated in)
	star1.visible = false
	star2.visible = false
	star3.visible = false
	star1.modulate.a = 0
	star2.modulate.a = 0
	star3.modulate.a = 0
	star1.scale = Vector2(0.5, 0.5)
	star2.scale = Vector2(0.5, 0.5)
	star3.scale = Vector2(0.5, 0.5)

	print("Level Complete screen initialized: Level %d, Stars: %d" % [completed_level_id, stars_earned])

## Animate stars appearing
func _animate_stars() -> void:
	# Wait a moment before showing stars
	await get_tree().create_timer(0.5).timeout

	# Animate each star sequentially
	for i in range(stars_earned):
		var star_label: Label
		match i:
			0:
				star_label = star1
			1:
				star_label = star2
			2:
				star_label = star3
			_:
				continue

		# Show star
		star_label.visible = true

		# Create tween for pop-in effect
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(star_label, "modulate:a", 1.0, 0.3)
		tween.tween_property(star_label, "scale", Vector2(1.2, 1.2), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

		# Scale back to normal
		tween.chain().tween_property(star_label, "scale", Vector2(1.0, 1.0), 0.1)

		# Wait before next star
		await get_tree().create_timer(0.2).timeout

	print("Stars animation completed")

## Handle Continue button
func _on_continue_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Determine next action based on completion
	_navigate_next()

## Navigate to next screen
func _navigate_next() -> void:
	# Check if there's a next level
	var next_level_id = completed_level_id + 1
	var total_levels = LevelManager.get_total_levels()

	# Logic based on GAME-RULES.md:
	# - If next level exists and we completed Easy → Navigate to next level Gameplay (Easy)
	# - If last level → Navigate to Level Selection
	# - If completed Normal/Hard → Navigate to Level Selection

	if completed_difficulty == GameConstants.Difficulty.EASY:
		# Check if next level exists
		if next_level_id <= total_levels:
			# Navigate to next level on Easy
			print("Navigating to next level: %d" % next_level_id)
			GameManager.navigate_to_gameplay(next_level_id, GameConstants.Difficulty.EASY)
		else:
			# Last level - return to level selection
			print("Last level completed, returning to level selection")
			GameManager.navigate_to_level_selection()
	else:
		# Completed Normal or Hard - return to level selection
		print("Completed higher difficulty, returning to level selection")
		GameManager.navigate_to_level_selection()

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
