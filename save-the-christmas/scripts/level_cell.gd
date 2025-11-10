extends PanelContainer

## Level Cell Component
## Displays level thumbnail, stars, and handles click interaction

signal level_clicked(level_id: int)

var level_id: int = 0
var is_unlocked: bool = false
var is_beaten: bool = false
var star_count: int = 0

@onready var thumbnail: TextureRect = $MarginContainer/Content/Thumbnail
@onready var level_number_label: Label = $MarginContainer/Content/LevelNumberBg/LevelNumberLabel
@onready var star1: Label = $MarginContainer/Content/StarsContainer/Star1
@onready var star2: Label = $MarginContainer/Content/StarsContainer/Star2
@onready var star3: Label = $MarginContainer/Content/StarsContainer/Star3
@onready var overlay_icon: Label = $MarginContainer/Content/OverlayIcon
@onready var level_number_bg: Panel = $MarginContainer/Content/LevelNumberBg

## Setup level cell with data
func setup(p_level_id: int, thumbnail_texture: Texture2D, p_star_count: int, p_is_unlocked: bool, p_is_beaten: bool) -> void:
	level_id = p_level_id
	star_count = p_star_count
	is_unlocked = p_is_unlocked
	is_beaten = p_is_beaten

	# Set level number
	level_number_label.text = str(level_id)

	# Set thumbnail
	if thumbnail_texture != null:
		thumbnail.texture = thumbnail_texture

	# Update visual state
	_update_visual_state()

## Update visual appearance based on state
func _update_visual_state() -> void:
	if not is_unlocked:
		# Locked state
		_set_locked_appearance()
	elif is_beaten:
		# Beaten state (has stars)
		_set_beaten_appearance()
	else:
		# Unlocked but not beaten
		_set_unlocked_appearance()

## Set locked appearance
func _set_locked_appearance() -> void:
	# Desaturate thumbnail
	thumbnail.modulate = Color(0.5, 0.5, 0.5, 1.0)

	# Grey border
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.3, 0.3, 0.3, 1.0)
	style_box.border_width_left = 4
	style_box.border_width_top = 4
	style_box.border_width_right = 4
	style_box.border_width_bottom = 4
	style_box.border_color = Color(0.5, 0.5, 0.5, 1.0)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style_box)

	# Show lock icon
	overlay_icon.text = "🔒"
	overlay_icon.visible = true
	overlay_icon.modulate = Color(1, 1, 1, 0.8)

	# Hide stars
	star1.visible = false
	star2.visible = false
	star3.visible = false

## Set unlocked appearance (not beaten yet)
func _set_unlocked_appearance() -> void:
	# Full color thumbnail
	thumbnail.modulate = Color(1, 1, 1, 1)

	# Green border
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	style_box.border_width_left = 4
	style_box.border_width_top = 4
	style_box.border_width_right = 4
	style_box.border_width_bottom = 4
	style_box.border_color = Color(0.09, 0.36, 0.2, 1.0)  # Green
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style_box)

	# Show play icon
	overlay_icon.text = "▶"
	overlay_icon.visible = true
	overlay_icon.modulate = Color(1, 1, 1, 0.6)

	# Show empty stars
	star1.visible = true
	star2.visible = true
	star3.visible = true
	star1.text = "☆"
	star2.text = "☆"
	star3.text = "☆"
	star1.modulate = Color(0.7, 0.7, 0.7, 1.0)
	star2.modulate = Color(0.7, 0.7, 0.7, 1.0)
	star3.modulate = Color(0.7, 0.7, 0.7, 1.0)

## Set beaten appearance (has stars)
func _set_beaten_appearance() -> void:
	# Full color thumbnail
	thumbnail.modulate = Color(1, 1, 1, 1)

	# Gold border
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	style_box.border_width_left = 4
	style_box.border_width_top = 4
	style_box.border_width_right = 4
	style_box.border_width_bottom = 4
	style_box.border_color = Color(1.0, 0.84, 0.0, 1.0)  # Gold
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style_box)

	# Hide overlay icon (no play icon for beaten levels)
	overlay_icon.visible = false

	# Show stars based on count
	star1.visible = true
	star2.visible = true
	star3.visible = true

	var gold_color = Color(1.0, 0.84, 0.0, 1.0)
	var empty_color = Color(0.5, 0.5, 0.5, 1.0)

	if star_count >= 1:
		star1.text = "★"
		star1.modulate = gold_color
	else:
		star1.text = "☆"
		star1.modulate = empty_color

	if star_count >= 2:
		star2.text = "★"
		star2.modulate = gold_color
	else:
		star2.text = "☆"
		star2.modulate = empty_color

	if star_count >= 3:
		star3.text = "★"
		star3.modulate = gold_color
	else:
		star3.text = "☆"
		star3.modulate = empty_color

## Handle button press
func _on_button_pressed() -> void:
	if not is_unlocked:
		# Show message for locked level
		print("Level ", level_id, " is locked. Complete previous level to unlock.")
		# TODO: Show toast/popup message
		return

	# Play click sound
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Emit signal
	level_clicked.emit(level_id)

	# Animate button press
	_animate_press()

## Animate button press feedback
func _animate_press() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
