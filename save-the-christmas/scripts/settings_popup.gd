extends Control

## Settings Popup (Modal)
## Displays game settings with toggles and action buttons

signal settings_closed

# UI Node references
@onready var overlay = $Overlay
@onready var sound_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/SoundToggle/ToggleButton
@onready var music_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/MusicToggle/ToggleButton
@onready var vibration_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/VibrationToggle/ToggleButton

# Colors for toggle states
const COLOR_ON = Color(0.2, 0.7, 0.3, 1.0)  # Green
const COLOR_OFF = Color(0.4, 0.4, 0.4, 1.0)  # Gray

func _ready() -> void:
	_load_settings()
	_update_all_toggle_visuals()

## Load current settings from ProgressManager
func _load_settings() -> void:
	# Settings are loaded from ProgressManager
	# Visual updates handled by _update_all_toggle_visuals()
	pass

## Update all toggle button visuals based on current settings
func _update_all_toggle_visuals() -> void:
	if ProgressManager:
		_update_toggle_visual(sound_toggle, ProgressManager.sound_enabled)
		_update_toggle_visual(music_toggle, ProgressManager.music_enabled)
		_update_toggle_visual(vibration_toggle, ProgressManager.vibrations_enabled)

## Update a single toggle button's appearance
func _update_toggle_visual(button: Button, is_on: bool) -> void:
	if is_on:
		button.text = "ON"
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)

		# Create green StyleBox for ON state
		var style_on = StyleBoxFlat.new()
		style_on.bg_color = COLOR_ON
		style_on.corner_radius_top_left = 12
		style_on.corner_radius_top_right = 12
		style_on.corner_radius_bottom_left = 12
		style_on.corner_radius_bottom_right = 12
		button.add_theme_stylebox_override("normal", style_on)
		button.add_theme_stylebox_override("hover", style_on)
		button.add_theme_stylebox_override("pressed", style_on)
	else:
		button.text = "OFF"
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)

		# Create gray StyleBox for OFF state
		var style_off = StyleBoxFlat.new()
		style_off.bg_color = COLOR_OFF
		style_off.corner_radius_top_left = 12
		style_off.corner_radius_top_right = 12
		style_off.corner_radius_bottom_left = 12
		style_off.corner_radius_bottom_right = 12
		button.add_theme_stylebox_override("normal", style_off)
		button.add_theme_stylebox_override("hover", style_off)
		button.add_theme_stylebox_override("pressed", style_off)

## Save current settings via ProgressManager
func _save_settings() -> void:
	if ProgressManager:
		ProgressManager.save_progress()

## Handle Sound toggle button pressed
func _on_sound_toggle_pressed() -> void:
	if AudioManager and ProgressManager:
		# Toggle the state
		var new_state = not ProgressManager.sound_enabled
		AudioManager.set_sound_enabled(new_state)

		# Update visual
		_update_toggle_visual(sound_toggle, new_state)
		_save_settings()

		# Play feedback sound if enabled
		if new_state:
			AudioManager.play_sfx("button_click")

## Handle Music toggle button pressed
func _on_music_toggle_pressed() -> void:
	if AudioManager and ProgressManager:
		# Toggle the state
		var new_state = not ProgressManager.music_enabled
		AudioManager.set_music_enabled(new_state)

		# Update visual
		_update_toggle_visual(music_toggle, new_state)
		_save_settings()

## Handle Vibration toggle button pressed
func _on_vibration_toggle_pressed() -> void:
	if ProgressManager:
		# Toggle the state
		var new_state = not ProgressManager.vibrations_enabled
		ProgressManager.vibrations_enabled = new_state

		# Update visual
		_update_toggle_visual(vibration_toggle, new_state)
		_save_settings()

## Handle Close button pressed
func _on_close_button_pressed() -> void:
	_close_popup()

## Handle overlay clicked (close on outside tap)
func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_close_popup()

## Close the popup
func _close_popup() -> void:
	_save_settings()
	settings_closed.emit()
	queue_free()

## Handle Send Feedback button
func _on_feedback_button_pressed() -> void:
	print("Send Feedback pressed")
	# TODO: Implement feedback mechanism
	# Option 1: Open email client
	# OS.shell_open("mailto:support@example.com?subject=Save%20the%20Christmas%20Feedback")

	# Option 2: Open web form
	# OS.shell_open("https://example.com/feedback")

	# For MVP, placeholder
	if AudioManager:
		AudioManager.play_sfx("button_click")

## Handle Remove Ads button (IAP)
func _on_remove_ads_button_pressed() -> void:
	print("Remove Ads pressed")
	# TODO: Implement IAP for removing ads
	# This will integrate with platform-specific IAP systems (Google Play, App Store)

	# For MVP, placeholder
	if AudioManager:
		AudioManager.play_sfx("button_click")

## Handle Privacy button - open privacy policy
func _on_privacy_button_pressed() -> void:
	print("Privacy button pressed")
	# TODO: Replace with actual privacy policy URL
	OS.shell_open("https://example.com/privacy")

	if AudioManager:
		AudioManager.play_sfx("button_click")

## Handle Terms button - open terms & conditions
func _on_terms_button_pressed() -> void:
	print("Terms button pressed")
	# TODO: Replace with actual terms URL
	OS.shell_open("https://example.com/terms")

	if AudioManager:
		AudioManager.play_sfx("button_click")
