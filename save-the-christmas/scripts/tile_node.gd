extends Control

## TileNode - Visual representation of a puzzle tile
## Handles display, selection, and interaction

signal tile_clicked(tile_node)

# Tile data
var tile_data: Tile
var tile_index: int = -1
var is_selected: bool = false

# Node references
@onready var tile_texture: TextureRect = $TileTexture
@onready var selection_border: Panel = $SelectionBorder
@onready var touch_area: Control = $TouchArea

# Animation
var tween: Tween

## Setup the tile with data and texture
func setup(tile: Tile, index: int, source_texture: Texture2D) -> void:
	tile_data = tile
	tile_index = index

	# Create AtlasTexture for the tile region
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = source_texture
	atlas_texture.region = tile.texture_region

	tile_texture.texture = atlas_texture

	# Configure border styling (white border between tiles)
	# The selection border will be styled differently
	_update_selection_visual()

## Set selection state
func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_selection_visual()

	if selected:
		# Scale up slightly when selected
		_animate_scale(GameConstants.TILE_SELECTION_SCALE)
	else:
		# Return to normal scale
		_animate_scale(1.0)

## Update visual appearance based on selection
func _update_selection_visual() -> void:
	selection_border.visible = is_selected

	if is_selected:
		# Gold border for selected tile
		var stylebox = StyleBoxFlat.new()
		stylebox.border_color = Color(1.0, 0.843, 0.0, 1.0)  # Gold
		stylebox.border_width_left = 8
		stylebox.border_width_top = 8
		stylebox.border_width_right = 8
		stylebox.border_width_bottom = 8
		stylebox.bg_color = Color(0, 0, 0, 0)  # Transparent background
		selection_border.add_theme_stylebox_override("panel", stylebox)

## Animate tile to a new grid position
func animate_to_position(target_position: Vector2, duration: float = GameConstants.TILE_SWAP_DURATION) -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_position, duration)

## Animate scale change
func _animate_scale(target_scale: float) -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), 0.1)

## Handle touch/click input
func _on_touch_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_tile_tapped()

## Handle tile tap
func _on_tile_tapped() -> void:
	# Play click sound
	if AudioManager:
		AudioManager.play_sfx("button_click")

	# Trigger haptic feedback
	if AudioManager:
		AudioManager.trigger_haptic(0.3)

	# Emit signal for gameplay screen to handle
	tile_clicked.emit(self)
