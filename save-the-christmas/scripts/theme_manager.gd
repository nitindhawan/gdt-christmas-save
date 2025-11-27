extends Node

## ThemeManager AutoLoad Singleton
## Centralized theme and color management for consistent styling

# Color palette (based on new design)
const COLOR_PRIMARY_GREEN = Color(0.086, 0.357, 0.2, 1.0)  # #165B33
const COLOR_PRIMARY_RED = Color(0.6, 0.1, 0.1, 1.0)
const COLOR_SECONDARY_GOLD = Color(1.0, 0.843, 0.0, 1.0)
const COLOR_BACKGROUND_DARK = Color(0.1, 0.1, 0.15, 1.0)
const COLOR_TEXT_PRIMARY = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_BUTTON_DISABLED = Color(0.46, 0.46, 0.46, 0.5)
const COLOR_TOGGLE_ON = Color(0.2, 0.7, 0.3, 1.0)
const COLOR_TOGGLE_OFF = Color(0.4, 0.4, 0.4, 1.0)

## Create a styled button background
static func create_button_style(bg_color: Color, corner_radius: int = 16) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	return style

## Apply consistent theme to a button
static func apply_button_theme(button: Button, color: Color, text: String) -> void:
	button.text = text
	button.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	var style = create_button_style(color)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
