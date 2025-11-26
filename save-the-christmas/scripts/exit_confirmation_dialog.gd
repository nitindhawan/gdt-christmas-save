extends Control

## Exit Confirmation Dialog (Custom Modal)
## Displays confirmation before exiting level

signal exit_confirmed
signal stay_pressed

# UI Node references
@onready var overlay = $Overlay
@onready var exit_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ButtonContainer/ExitButton
@onready var stay_button = $CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ButtonContainer/StayButton

# Colors for button states
const COLOR_RED = Color(0.77, 0.12, 0.23, 1.0)  # #C41E3A
const COLOR_RED_PRESSED = Color(0.65, 0.1, 0.2, 1.0)  # Darker red
const COLOR_GREEN = Color(0.09, 0.36, 0.2, 1.0)  # #165B33
const COLOR_GREEN_PRESSED = Color(0.07, 0.3, 0.17, 1.0)  # Darker green

func _ready() -> void:
	_style_buttons()

## Style the exit and stay buttons
func _style_buttons() -> void:
	# Exit button (Red - warning action)
	var exit_style = StyleBoxFlat.new()
	exit_style.bg_color = COLOR_RED
	exit_style.corner_radius_top_left = 20
	exit_style.corner_radius_top_right = 20
	exit_style.corner_radius_bottom_left = 20
	exit_style.corner_radius_bottom_right = 20

	var exit_style_pressed = StyleBoxFlat.new()
	exit_style_pressed.bg_color = COLOR_RED_PRESSED
	exit_style_pressed.corner_radius_top_left = 20
	exit_style_pressed.corner_radius_top_right = 20
	exit_style_pressed.corner_radius_bottom_left = 20
	exit_style_pressed.corner_radius_bottom_right = 20

	exit_button.add_theme_stylebox_override("normal", exit_style)
	exit_button.add_theme_stylebox_override("hover", exit_style)
	exit_button.add_theme_stylebox_override("pressed", exit_style_pressed)
	exit_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	exit_button.add_theme_color_override("font_hover_color", Color.WHITE)

	# Stay button (Green - safe action)
	var stay_style = StyleBoxFlat.new()
	stay_style.bg_color = COLOR_GREEN
	stay_style.corner_radius_top_left = 20
	stay_style.corner_radius_top_right = 20
	stay_style.corner_radius_bottom_left = 20
	stay_style.corner_radius_bottom_right = 20

	var stay_style_pressed = StyleBoxFlat.new()
	stay_style_pressed.bg_color = COLOR_GREEN_PRESSED
	stay_style_pressed.corner_radius_top_left = 20
	stay_style_pressed.corner_radius_top_right = 20
	stay_style_pressed.corner_radius_bottom_left = 20
	stay_style_pressed.corner_radius_bottom_right = 20

	stay_button.add_theme_stylebox_override("normal", stay_style)
	stay_button.add_theme_stylebox_override("hover", stay_style)
	stay_button.add_theme_stylebox_override("pressed", stay_style_pressed)
	stay_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	stay_button.add_theme_color_override("font_hover_color", Color.WHITE)

## Handle Exit button pressed
func _on_exit_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")
	exit_confirmed.emit()
	queue_free()

## Handle Stay button pressed
func _on_stay_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")
	stay_pressed.emit()
	queue_free()

## Handle overlay clicked (close on outside tap)
func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Treat overlay click same as "Stay"
			_on_stay_button_pressed()
