extends Control

## TileNode - Visual representation of a puzzle tile
## Handles display, drag-and-drop interaction

signal drag_started(tile_node)
signal drag_ended(tile_node, target_tile_node)
signal hover_changed(tile_node, is_hovering, target_tile_node)

# Tile data (can be Tile or RowTile)
var tile_data  # Untyped to support both Tile and RowTile
var tile_index: int = -1
var is_draggable: bool = true
var is_being_dragged: bool = false
var is_hovered: bool = false

# Drag state
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var original_z_index: int = 0
var hover_target: Control = null

# Node references
@onready var tile_texture: TextureRect = $TileTexture
@onready var border: Panel = $Border
@onready var touch_area: Control = $TouchArea

# Animation
var tween: Tween

## Setup the tile with data and texture
func setup(tile: Tile, index: int, source_texture: Texture2D, zoom_factor: float = 1.0) -> void:
	tile_data = tile
	tile_index = index

	# Create AtlasTexture for the tile region
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = source_texture
	atlas_texture.region = tile.texture_region

	tile_texture.texture = atlas_texture

	# Note: TextureRect stretch modes are set in scene (expand_mode=1, stretch_mode=6)
	# expand_mode=1 (EXPAND_IGNORE_SIZE) ignores texture size, uses container size
	# stretch_mode=6 (STRETCH_KEEP_ASPECT_COVERED) scales to cover container maintaining aspect ratio
	# clip_contents=true clips overflow on edges

	# Check if tile is in correct position
	is_draggable = !tile.is_correct()

	# Configure visual appearance
	_update_border_visual()

## Setup the tile for row tile puzzle (similar to setup but for RowTile)
func setup_row_tile(row_data, index: int, source_texture: Texture2D) -> void:
	tile_data = row_data  # Store as tile_data for compatibility
	tile_index = index

	# Create AtlasTexture for the row region
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = source_texture
	atlas_texture.region = row_data.texture_region

	tile_texture.texture = atlas_texture

	# Row tiles are always draggable until in correct position
	is_draggable = !row_data.is_correct()

	# Configure visual appearance
	_update_border_visual()

## Update draggable status (call when tile position changes)
func update_draggable_status() -> void:
	is_draggable = !tile_data.is_correct()
	_update_border_visual()

## Update visual appearance based on draggable status
func _update_border_visual() -> void:
	if is_draggable:
		# Apply draggable border theme
		border.visible = true
		ThemeManager.apply_tile_border_theme(border, true)
	else:
		# No border for correct tiles
		border.visible = false

## Set hover state (shrink when another tile hovers over this)
func set_hover_target(is_target: bool) -> void:
	is_hovered = is_target
	if is_target:
		_animate_scale(ThemeManager.SCALE_PRESSED)  # Shrink slightly
	else:
		_animate_scale(1.0)  # Return to normal

## Animate scale change
func _animate_scale(target_scale: float) -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_ease(ThemeManager.EASE_TILE)
	tween.set_trans(ThemeManager.TRANS_TILE)
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), ThemeManager.ANIM_INSTANT)

## Handle input for drag-and-drop
func _on_touch_area_gui_input(event: InputEvent) -> void:
	if !is_draggable:
		return  # Non-draggable tiles don't respond to input

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag()
	elif event is InputEventMouseMotion:
		if is_being_dragged:
			_update_drag(event.position)

## Start dragging this tile
func _start_drag(click_position: Vector2) -> void:
	is_being_dragged = true
	drag_offset = click_position
	original_position = global_position
	original_z_index = z_index

	# Bring to front
	z_index = 100

	# Scale up slightly
	_animate_scale(ThemeManager.SCALE_DRAG)

	# Play sound
	if AudioManager:
		AudioManager.play_sfx("tile_pickup")

	# Trigger haptic
	if AudioManager:
		AudioManager.trigger_haptic(0.3)

	drag_started.emit(self)

## Update drag position
func _update_drag(mouse_position: Vector2) -> void:
	if !is_being_dragged:
		return

	# Move tile to follow mouse/touch
	global_position = get_global_mouse_position() - drag_offset

	# Check if hovering over another tile
	_check_hover_target()

## Check which tile we're hovering over
func _check_hover_target() -> void:
	var new_target = null
	var mouse_pos = get_global_mouse_position()

	# Get parent (should be PuzzleGrid)
	var grid = get_parent()
	if grid:
		for child in grid.get_children():
			if child != self and child is Control:
				# Only consider tiles that are draggable (not in correct position)
				if "is_draggable" in child and !child.is_draggable:
					continue

				var rect = Rect2(child.global_position, child.size)
				if rect.has_point(mouse_pos):
					new_target = child
					break

	# Update hover state if changed
	if new_target != hover_target:
		# Remove hover from old target
		if hover_target and hover_target.has_method("set_hover_target"):
			hover_target.set_hover_target(false)
			hover_changed.emit(self, false, hover_target)

		# Add hover to new target
		hover_target = new_target
		if hover_target and hover_target.has_method("set_hover_target"):
			hover_target.set_hover_target(true)
			hover_changed.emit(self, true, hover_target)

## End dragging
func _end_drag() -> void:
	if !is_being_dragged:
		return

	is_being_dragged = false

	# Reset z-index
	z_index = original_z_index

	# Reset scale
	_animate_scale(1.0)

	# Clear hover from target
	if hover_target and hover_target.has_method("set_hover_target"):
		hover_target.set_hover_target(false)

	# Play sound
	if AudioManager:
		AudioManager.play_sfx("tile_drop")

	# Emit end signal with target
	drag_ended.emit(self, hover_target)

	# Reset drag state
	hover_target = null
