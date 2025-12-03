extends Control

## Settings Popup (Modal)
## Displays game settings with toggles and action buttons

signal settings_closed

# UI Node references
@onready var overlay = $Overlay
@onready var title_label = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/Header/TitleLabel
@onready var close_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var sound_label = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/SoundToggle/Label
@onready var sound_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/SoundToggle/ToggleButton
@onready var music_label = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/MusicToggle/Label
@onready var music_toggle = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ToggleSection/MusicToggle/ToggleButton
@onready var feedback_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ButtonSection/FeedbackButton
@onready var remove_ads_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ButtonSection/RemoveAdsButton
@onready var reset_progress_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ButtonSection/ResetProgressButton
@onready var privacy_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/FooterLinks/PrivacyButton
@onready var separator_label = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/FooterLinks/Separator
@onready var terms_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/FooterLinks/TermsButton

func _ready() -> void:
	_apply_theme()
	_load_settings()
	_update_all_toggle_visuals()

func _apply_theme() -> void:
	# Apply font sizes from ThemeManager
	# Note: close_button is now a TextureButton, no font theme needed
	ThemeManager.apply_xlarge(title_label, ThemeManager.COLOR_TEXT_SECONDARY)
	ThemeManager.apply_large(sound_label, ThemeManager.COLOR_TEXT_SECONDARY)
	ThemeManager.apply_large(sound_toggle)
	ThemeManager.apply_large(music_label, ThemeManager.COLOR_TEXT_SECONDARY)
	ThemeManager.apply_large(music_toggle)
	ThemeManager.apply_large(feedback_button)
	ThemeManager.apply_large(remove_ads_button)
	ThemeManager.apply_large(reset_progress_button)
	ThemeManager.apply_large(privacy_button)
	ThemeManager.apply_small(separator_label, Color(0.5, 0.5, 0.5, 1.0))
	ThemeManager.apply_large(terms_button)

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

## Update a single toggle button's appearance
func _update_toggle_visual(button: Button, is_on: bool) -> void:
	var color = ThemeManager.COLOR_TOGGLE_ON if is_on else ThemeManager.COLOR_TOGGLE_OFF
	var text = "ON" if is_on else "OFF"
	ThemeManager.apply_button_theme(button, color, text)

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

## Handle Reset Progress button - reset all game progress to level 1
func _on_reset_progress_button_pressed() -> void:
	print("Reset Progress pressed")

	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Reset all progress via ProgressManager
	if ProgressManager:
		ProgressManager.reset_progress()
		print("Game progress reset to level 1")

		# Close the settings popup
		_close_popup()

		# Navigate to gameplay screen for level 1 (will show difficulty popup)
		if GameManager:
			GameManager.navigate_to_gameplay_new_flow(1)
