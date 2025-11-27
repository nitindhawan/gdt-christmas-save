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

func _ready() -> void:
	_apply_theme()

func _apply_theme() -> void:
	# Apply font sizes from ThemeManager
	# level_number_label: 24 → 24 (SMALL) ✓
	# stars: 40 → 32 (MEDIUM)
	# overlay_icon: 80 → 80 (XLARGE) ✓
	ThemeManager.apply_small(level_number_label)
	ThemeManager.apply_medium(star1)
	ThemeManager.apply_medium(star2)
	ThemeManager.apply_medium(star3)
	ThemeManager.apply_xlarge(overlay_icon)

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
	# Apply theme styling
	ThemeManager.apply_level_cell_theme(self, ThemeManager.LevelState.LOCKED)
	thumbnail.modulate = ThemeManager.get_level_cell_modulation(ThemeManager.LevelState.LOCKED)

	# Show lock icon
	overlay_icon.text = "🔒"
	overlay_icon.visible = true
	overlay_icon.modulate = ThemeManager.get_level_cell_icon_modulation(ThemeManager.LevelState.LOCKED)

	# Hide stars
	star1.visible = false
	star2.visible = false
	star3.visible = false

## Set unlocked appearance (not beaten yet)
func _set_unlocked_appearance() -> void:
	# Apply theme styling
	ThemeManager.apply_level_cell_theme(self, ThemeManager.LevelState.UNLOCKED)
	thumbnail.modulate = ThemeManager.get_level_cell_modulation(ThemeManager.LevelState.UNLOCKED)

	# Show play icon
	overlay_icon.text = "▶"
	overlay_icon.visible = true
	overlay_icon.modulate = ThemeManager.get_level_cell_icon_modulation(ThemeManager.LevelState.UNLOCKED)

	# Show empty stars
	star1.visible = true
	star2.visible = true
	star3.visible = true
	star1.text = "☆"
	star2.text = "☆"
	star3.text = "☆"
	var empty_star_color = Color(0.7, 0.7, 0.7, 1.0)
	star1.modulate = empty_star_color
	star2.modulate = empty_star_color
	star3.modulate = empty_star_color

## Set beaten appearance (has stars)
func _set_beaten_appearance() -> void:
	# Apply theme styling
	ThemeManager.apply_level_cell_theme(self, ThemeManager.LevelState.BEATEN)
	thumbnail.modulate = ThemeManager.get_level_cell_modulation(ThemeManager.LevelState.BEATEN)

	# Hide overlay icon (no play icon for beaten levels)
	overlay_icon.visible = false

	# Show stars based on count
	star1.visible = true
	star2.visible = true
	star3.visible = true

	var gold_color = ThemeManager.COLOR_ACCENT
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
	tween.set_ease(ThemeManager.EASE_BUTTON)
	tween.set_trans(ThemeManager.TRANS_BUTTON)
	tween.tween_property(self, "scale", Vector2(ThemeManager.SCALE_PRESSED, ThemeManager.SCALE_PRESSED), ThemeManager.ANIM_INSTANT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), ThemeManager.ANIM_INSTANT)
