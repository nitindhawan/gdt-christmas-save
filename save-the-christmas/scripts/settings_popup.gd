extends Control

## Settings Popup (Modal)
## Displays game settings with toggles and action buttons

signal settings_closed

# UI Node references
@onready var overlay = $Overlay
@onready var sound_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/SoundToggle/CheckButton
@onready var music_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/MusicToggle/CheckButton
@onready var vibration_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/VibrationToggle/CheckButton

func _ready() -> void:
	_load_settings()

## Load current settings from AudioManager
func _load_settings() -> void:
	if AudioManager:
		sound_toggle.button_pressed = AudioManager.sound_enabled
		music_toggle.button_pressed = AudioManager.music_enabled
		vibration_toggle.button_pressed = AudioManager.vibrations_enabled

## Save current settings via AudioManager
func _save_settings() -> void:
	if AudioManager:
		AudioManager.save_settings()

## Handle Sound toggle changed
func _on_sound_toggle_toggled(button_pressed: bool) -> void:
	if AudioManager:
		AudioManager.sound_enabled = button_pressed
		_save_settings()

		# Play feedback sound if enabled
		if button_pressed:
			AudioManager.play_sfx("button_click")

## Handle Music toggle changed
func _on_music_toggle_toggled(button_pressed: bool) -> void:
	if AudioManager:
		AudioManager.music_enabled = button_pressed
		_save_settings()

		# Toggle music playback
		if button_pressed:
			AudioManager.play_music()
		else:
			AudioManager.stop_music()

## Handle Vibration toggle changed
func _on_vibration_toggle_toggled(button_pressed: bool) -> void:
	if AudioManager:
		AudioManager.vibrations_enabled = button_pressed
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
