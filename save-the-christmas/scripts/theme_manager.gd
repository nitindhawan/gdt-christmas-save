extends Node

## ThemeManager AutoLoad Singleton
## Centralized theme and color management for consistent styling

# ============================================================================
# TYPOGRAPHY SYSTEM (4 Core Sizes)
# ============================================================================

# 4 essential font sizes for the entire game
const FONT_SIZE_XLARGE = 80   # Titles, large icons, stars
const FONT_SIZE_LARGE = 64    # Section headers, main buttons, labels
const FONT_SIZE_MEDIUM = 32   # Normal text, smaller buttons
const FONT_SIZE_SMALL = 24    # Small text, badges

# ============================================================================
# COLOR SYSTEM (Semantic Colors)
# ============================================================================
# New Christmas Color Palette:
# - Snow White (#F0F8FF): Large snowy areas, backgrounds, clean text
# - Rich Christmas Red (#B3001B): Primary actions, accents, ribbons
# - Forest Green (#0B6623): Secondary actions, toggle ON state
# - Warm Gold (#FFD700): Stars, lights, borders, score/level text
# - Deep Night Blue (#081C30): Night sky, modal backdrops

# === PRIMARY PALETTE ===
const COLOR_PRIMARY = Color(0.043, 0.4, 0.137, 1.0)          # #0B6623 Forest Green
const COLOR_PRIMARY_DARK = Color(0.03, 0.28, 0.096, 1.0)     # Darker variant
const COLOR_PRIMARY_LIGHT = Color(0.06, 0.52, 0.18, 1.0)     # Lighter variant

const COLOR_SECONDARY = Color(0.702, 0.0, 0.106, 1.0)        # #B3001B Rich Christmas Red
const COLOR_SECONDARY_DARK = Color(0.5, 0.0, 0.075, 1.0)     # Darker variant
const COLOR_SECONDARY_LIGHT = Color(0.85, 0.0, 0.13, 1.0)    # Lighter variant

const COLOR_ACCENT = Color(1.0, 0.843, 0.0, 1.0)             # #FFD700 Warm Gold
const COLOR_ACCENT_DIM = Color(0.7, 0.6, 0.0, 1.0)           # Dimmed gold

# === BACKGROUND COLORS ===
const COLOR_BG_DARKEST = Color(0.031, 0.11, 0.188, 1.0)      # #081C30 Deep Night Blue
const COLOR_BG_DARK = Color(0.047, 0.165, 0.282, 1.0)        # Lighter night blue (panels)
const COLOR_BG_LIGHT = Color(0.941, 0.973, 1.0, 1.0)         # #F0F8FF Snow White
const COLOR_BG_GAME = Color(0.031, 0.11, 0.188, 1.0)         # Deep Night Blue (gameplay)
const COLOR_BG_DIFFICULTY = Color(0.047, 0.165, 0.282, 1.0)  # Lighter night blue
const COLOR_BG_WIN = Color(0.047, 0.165, 0.282, 1.0)         # Lighter night blue

# === TEXT COLORS ===
const COLOR_TEXT_PRIMARY = Color(0.941, 0.973, 1.0, 1.0)     # #F0F8FF Snow White
const COLOR_TEXT_SECONDARY = Color(0.8, 0.85, 0.9, 1.0)      # Slightly dimmed snow white
const COLOR_TEXT_DISABLED = Color(0.5, 0.5, 0.5, 1.0)        # Gray

# === STATE COLORS ===
const COLOR_STATE_SUCCESS = COLOR_ACCENT
const COLOR_STATE_LOCKED = Color(0.46, 0.46, 0.46, 0.5)
const COLOR_STATE_HOVER = Color(1.0, 1.0, 1.0, 0.1)

# === UI ELEMENT COLORS ===
const COLOR_BORDER_DEFAULT = Color(0.3, 0.3, 0.3, 1.0)       # Dark grey
const COLOR_BORDER_PRIMARY = COLOR_PRIMARY                    # Green
const COLOR_BORDER_ACCENT = COLOR_ACCENT                      # Gold
const COLOR_BORDER_LOCKED = Color(0.5, 0.5, 0.5, 1.0)

const COLOR_TOGGLE_ON = COLOR_PRIMARY                         # #0B6623 Forest Green (Active)
const COLOR_TOGGLE_OFF = Color(0.4, 0.4, 0.4, 1.0)           # Inactive grey

const COLOR_OVERLAY = Color(0.031, 0.11, 0.188, 0.9)         # Deep Night Blue overlay
const COLOR_SHADOW = Color(0, 0, 0, 0.4)                     # Black shadow

# === MODULATION COLORS ===
const COLOR_MOD_DESATURATE = Color(0.5, 0.5, 0.5, 1.0)       # Locked state
const COLOR_MOD_NORMAL = Color(1.0, 1.0, 1.0, 1.0)           # Full color
const COLOR_MOD_HIGHLIGHT = Color(1.05, 1.05, 1.05, 1.0)     # Slight glow

# === BACKWARD COMPATIBILITY (KEEP OLD NAMES) ===
const COLOR_PRIMARY_GREEN = COLOR_PRIMARY
const COLOR_PRIMARY_RED = COLOR_SECONDARY
const COLOR_SECONDARY_GOLD = COLOR_ACCENT
const COLOR_BACKGROUND_DARK = COLOR_BG_DARKEST
const COLOR_BUTTON_DISABLED = COLOR_STATE_LOCKED

# ============================================================================
# SPACING SYSTEM
# ============================================================================

# === CORE SPACING SCALE ===
const SPACING_NONE = 0
const SPACING_XS = 4       # Tiny (borders, tight padding)
const SPACING_SM = 10      # Small (HUD margins)
const SPACING_MD = 20      # Medium (container separation)
const SPACING_LG = 30      # Large (grid gaps, sections)
const SPACING_XL = 40      # Extra large (screen margins)
const SPACING_2XL = 50     # Huge (modal margins)
const SPACING_3XL = 60     # Massive (top safe area)

# === SEMANTIC SPACING ===
const MARGIN_SCREEN = SPACING_XL            # 40px
const MARGIN_SCREEN_TOP = SPACING_3XL       # 60px (safe area)
const MARGIN_MODAL = SPACING_2XL            # 50px
const MARGIN_PANEL = SPACING_SM             # 10px

const GAP_GRID = SPACING_XL                 # 40px
const GAP_CONTAINER = SPACING_MD            # 20px
const GAP_SECTION = SPACING_LG              # 30px
const GAP_STARS = SPACING_MD                # 20px

const PADDING_TIGHT = SPACING_XS            # 4px
const PADDING_NORMAL = SPACING_SM           # 10px
const PADDING_LOOSE = SPACING_LG            # 30px

# === COMPONENT SIZES ===
const BUTTON_MIN_SIZE_ICON = Vector2(80, 80)
const BUTTON_MIN_SIZE_TOGGLE = Vector2(240, 100)
const BUTTON_MIN_SIZE_WIDE = Vector2(850, 150)

const PANEL_SIZE_PREVIEW = Vector2(850, 850)
const PANEL_SIZE_MODAL = Vector2(850, 1200)
const PANEL_SIZE_LEVEL_CELL = Vector2(460, 560)

const HUD_HEIGHT_TOP = 100
const HUD_HEIGHT_BOTTOM = 180

# ============================================================================
# BORDER & CORNER SYSTEM
# ============================================================================

const BORDER_THIN = 2
const BORDER_NORMAL = 4
const BORDER_THICK = 6

const CORNER_RADIUS_SMALL = 8
const CORNER_RADIUS_MEDIUM = 16
const CORNER_RADIUS_LARGE = 20

const SHADOW_OFFSET = Vector2(0, 4)
const SHADOW_BLUR = 8

# ============================================================================
# ANIMATION SYSTEM
# ============================================================================

const ANIM_INSTANT = 0.1          # Button press
const ANIM_FAST = 0.15            # Arrow exit
const ANIM_NORMAL = 0.2           # Arrow bounce
const ANIM_SLOW = 0.3             # Tile swap, transitions
const ANIM_STAR_DELAY = 0.2       # Star sequence delay

const SCALE_PRESSED = 0.95
const SCALE_HOVER = 1.05
const SCALE_DRAG = 1.1

const EASE_BUTTON = Tween.EASE_OUT
const TRANS_BUTTON = Tween.TRANS_BACK
const EASE_TILE = Tween.EASE_OUT
const TRANS_TILE = Tween.TRANS_CUBIC

# ============================================================================
# ENUMS
# ============================================================================

enum LevelState { LOCKED, UNLOCKED, BEATEN }

# ============================================================================
# HELPER FUNCTIONS - Typography
# ============================================================================

## Apply font size to any label or button
static func apply_font_size(node: Control, size: int, color: Color = COLOR_TEXT_PRIMARY) -> void:
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)

## Convenience functions for common sizes
static func apply_xlarge(node: Control, color: Color = COLOR_TEXT_PRIMARY) -> void:
	apply_font_size(node, FONT_SIZE_XLARGE, color)

static func apply_large(node: Control, color: Color = COLOR_TEXT_PRIMARY) -> void:
	apply_font_size(node, FONT_SIZE_LARGE, color)

static func apply_medium(node: Control, color: Color = COLOR_TEXT_PRIMARY) -> void:
	apply_font_size(node, FONT_SIZE_MEDIUM, color)

static func apply_small(node: Control, color: Color = COLOR_TEXT_PRIMARY) -> void:
	apply_font_size(node, FONT_SIZE_SMALL, color)

# ============================================================================
# HELPER FUNCTIONS - Colors
# ============================================================================

## Get color for component state
static func get_state_color(state: String) -> Color:
	match state:
		"locked": return COLOR_STATE_LOCKED
		"unlocked": return COLOR_PRIMARY
		"beaten": return COLOR_ACCENT
		"disabled": return COLOR_BUTTON_DISABLED
		"success": return COLOR_STATE_SUCCESS
		_: return COLOR_TEXT_PRIMARY

## Get modulation color for visual state
static func get_modulation(state: String) -> Color:
	match state:
		"locked": return COLOR_MOD_DESATURATE
		"highlight": return COLOR_MOD_HIGHLIGHT
		"normal", _: return COLOR_MOD_NORMAL

## Get border color for state
static func get_border_color(state: String) -> Color:
	match state:
		"locked": return COLOR_BORDER_LOCKED
		"unlocked": return COLOR_BORDER_PRIMARY
		"beaten": return COLOR_BORDER_ACCENT
		"default", _: return COLOR_BORDER_DEFAULT

# ============================================================================
# HELPER FUNCTIONS - Spacing
# ============================================================================

## Apply screen margins
static func apply_screen_margins(container: MarginContainer, include_safe_area: bool = true) -> void:
	var top_margin = MARGIN_SCREEN_TOP if include_safe_area else MARGIN_SCREEN
	container.add_theme_constant_override("margin_left", MARGIN_SCREEN)
	container.add_theme_constant_override("margin_top", top_margin)
	container.add_theme_constant_override("margin_right", MARGIN_SCREEN)
	container.add_theme_constant_override("margin_bottom", MARGIN_SCREEN)

## Apply modal margins
static func apply_modal_margins(container: MarginContainer) -> void:
	apply_uniform_margin(container, MARGIN_MODAL)

## Apply uniform margin
static func apply_uniform_margin(container: MarginContainer, spacing: int) -> void:
	container.add_theme_constant_override("margin_left", spacing)
	container.add_theme_constant_override("margin_top", spacing)
	container.add_theme_constant_override("margin_right", spacing)
	container.add_theme_constant_override("margin_bottom", spacing)

## Set container separation (VBox/HBox)
static func set_container_separation(container: BoxContainer, spacing: int) -> void:
	container.add_theme_constant_override("separation", spacing)

## Set grid gaps
static func set_grid_gaps(grid: GridContainer, h_gap: int = GAP_GRID, v_gap: int = GAP_GRID) -> void:
	grid.add_theme_constant_override("h_separation", h_gap)
	grid.add_theme_constant_override("v_separation", v_gap)

# ============================================================================
# HELPER FUNCTIONS - StyleBoxFlat
# ============================================================================

## Set all corner radii uniformly
static func set_corner_radius(style: StyleBoxFlat, radius: int) -> void:
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

## Set all border widths uniformly
static func set_border_width(style: StyleBoxFlat, width: int) -> void:
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width

## Create border-only style (transparent background)
static func create_border_style(border_color: Color, border_width: int = BORDER_NORMAL, corner_radius: int = CORNER_RADIUS_SMALL) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)  # Transparent
	style.border_color = border_color
	set_border_width(style, border_width)
	set_corner_radius(style, corner_radius)
	return style

# ============================================================================
# HELPER FUNCTIONS - Panels
# ============================================================================

## Create standard panel
static func create_panel_style(bg_color: Color = COLOR_BG_DARK, corner_radius: int = CORNER_RADIUS_LARGE) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	set_corner_radius(style, corner_radius)
	return style

## Create bordered panel
static func create_bordered_panel_style(
	bg_color: Color,
	border_color: Color,
	border_width: int = BORDER_NORMAL,
	corner_radius: int = CORNER_RADIUS_SMALL
) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	set_border_width(style, border_width)
	set_corner_radius(style, corner_radius)
	return style

## Apply panel theme
static func apply_panel_theme(panel: PanelContainer, bg_color: Color = COLOR_BG_DARK, corner_radius: int = CORNER_RADIUS_LARGE) -> void:
	var style = create_panel_style(bg_color, corner_radius)
	panel.add_theme_stylebox_override("panel", style)

# ============================================================================
# HELPER FUNCTIONS - Level Cell Component
# ============================================================================

## Create level cell style for specific state
static func create_level_cell_style(state: LevelState) -> StyleBoxFlat:
	var bg_color: Color
	var border_color: Color

	match state:
		LevelState.LOCKED:
			bg_color = Color(0.3, 0.3, 0.3, 1.0)
			border_color = COLOR_BORDER_LOCKED
		LevelState.UNLOCKED:
			bg_color = Color(0.2, 0.2, 0.2, 1.0)
			border_color = COLOR_BORDER_PRIMARY
		LevelState.BEATEN:
			bg_color = Color(0.2, 0.2, 0.2, 1.0)
			border_color = COLOR_BORDER_ACCENT
		_:
			bg_color = COLOR_BG_DARK
			border_color = COLOR_BORDER_DEFAULT

	return create_bordered_panel_style(bg_color, border_color, BORDER_NORMAL, CORNER_RADIUS_SMALL)

## Apply level cell theme (replaces 20+ lines)
static func apply_level_cell_theme(panel: PanelContainer, state: LevelState) -> void:
	var style = create_level_cell_style(state)
	panel.add_theme_stylebox_override("panel", style)

## Get modulation for level cell state
static func get_level_cell_modulation(state: LevelState) -> Color:
	match state:
		LevelState.LOCKED: return COLOR_MOD_DESATURATE
		LevelState.UNLOCKED, LevelState.BEATEN: return COLOR_MOD_NORMAL
		_: return COLOR_MOD_NORMAL

## Get overlay icon modulation for level cell state
static func get_level_cell_icon_modulation(state: LevelState) -> Color:
	match state:
		LevelState.LOCKED: return Color(1, 1, 1, 0.8)
		LevelState.UNLOCKED: return Color(1, 1, 1, 0.6)
		_: return COLOR_MOD_NORMAL

# ============================================================================
# HELPER FUNCTIONS - Buttons
# ============================================================================

## Create a styled button background (legacy - kept for backward compatibility)
static func create_button_style(bg_color: Color, corner_radius: int = 16) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	set_corner_radius(style, corner_radius)
	return style

## Create a styled button background with content margins (padding)
static func create_button_style_with_padding(bg_color: Color, corner_radius: int = 16, padding: int = 20) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	set_corner_radius(style, corner_radius)
	# Add content margins for padding
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

## Apply consistent theme to a button (legacy - kept for backward compatibility)
static func apply_button_theme(button: Button, color: Color, text: String) -> void:
	button.text = text
	button.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	var style = create_button_style(color)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)

## Apply button theme with proper padding
static func apply_button_theme_with_padding(button: Button, color: Color, text: String, padding: int = 20) -> void:
	button.text = text
	button.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	var style = create_button_style_with_padding(color, CORNER_RADIUS_MEDIUM, padding)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)

## Apply complete button theme with all states (expanded version)
static func apply_button_theme_complete(
	button: Button,
	normal_color: Color,
	hover_color: Color = Color.TRANSPARENT,
	pressed_color: Color = Color.TRANSPARENT,
	disabled_color: Color = COLOR_STATE_LOCKED,
	text_color: Color = COLOR_TEXT_PRIMARY,
	corner_radius: int = CORNER_RADIUS_MEDIUM
) -> void:
	# Auto-generate hover/pressed if not specified
	var final_hover = hover_color if hover_color != Color.TRANSPARENT else normal_color.lightened(0.1)
	var final_pressed = pressed_color if pressed_color != Color.TRANSPARENT else normal_color.darkened(0.1)

	# Create styles
	var style_normal = create_button_style(normal_color, corner_radius)
	var style_hover = create_button_style(final_hover, corner_radius)
	var style_pressed = create_button_style(final_pressed, corner_radius)
	var style_disabled = create_button_style(disabled_color, corner_radius)

	# Apply to button
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_stylebox_override("disabled", style_disabled)
	button.add_theme_color_override("font_color", text_color)

## Apply icon button theme (80x80, dark background)
static func apply_icon_button_theme(button: Button, icon_text: String = "", size: Vector2 = BUTTON_MIN_SIZE_ICON) -> void:
	button.custom_minimum_size = size
	if icon_text != "":
		button.text = icon_text
	apply_button_theme_complete(button, COLOR_BG_DARK, Color.TRANSPARENT, Color.TRANSPARENT, COLOR_STATE_LOCKED, COLOR_TEXT_PRIMARY, CORNER_RADIUS_MEDIUM)

## Apply toggle button theme (ON/OFF)
static func apply_toggle_button_theme(button: Button, is_on: bool, text_on: String = "ON", text_off: String = "OFF") -> void:
	var color = COLOR_TOGGLE_ON if is_on else COLOR_TOGGLE_OFF
	var text = text_on if is_on else text_off
	apply_button_theme(button, color, text)

# ============================================================================
# HELPER FUNCTIONS - Tiles
# ============================================================================

## Create tile border style
static func create_tile_border_style(is_draggable: bool) -> StyleBoxFlat:
	if is_draggable:
		return create_border_style(COLOR_BORDER_DEFAULT, BORDER_NORMAL, 0)
	else:
		# No border for correct tiles
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		return style

## Apply tile border theme
static func apply_tile_border_theme(panel: Panel, is_draggable: bool) -> void:
	var style = create_tile_border_style(is_draggable)
	panel.add_theme_stylebox_override("panel", style)
