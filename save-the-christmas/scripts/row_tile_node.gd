extends Control

## RowTileNode - Visual representation of a row tile (horizontal strip)
## Handles display and VERTICAL-ONLY drag-and-drop interaction

signal drag_started(row_tile_node)
signal drag_ended(row_tile_node, target_row_tile_node)
signal hover_changed(row_tile_node, is_hovering, target_row_tile_node)

# Row tile data
var tile_data  # RowTile instance
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

## Setup the row tile with data and texture
func setup_row_tile(row_data, index: int, source_texture: Texture2D) -> void:
	tile_data = row_data
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

## Update draggable status (call when row position changes)
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
		# No border for correct rows
		border.visible = false

## Set hover state (shrink when another row hovers over this)
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

## Handle input for VERTICAL-ONLY drag-and-drop
func _on_touch_area_gui_input(event: InputEvent) -> void:
	if !is_draggable:
		return  # Non-draggable rows don't respond to input

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag()
	elif event is InputEventMouseMotion:
		if is_being_dragged:
			_update_drag(event.position)

## Start dragging this row tile
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

## Update drag position - VERTICAL ONLY (horizontal locked)
func _update_drag(mouse_position: Vector2) -> void:
	if !is_being_dragged:
		return

	# CRITICAL: Only allow vertical movement, lock horizontal position
	var new_y = get_global_mouse_position().y - drag_offset.y
	global_position = Vector2(original_position.x, new_y)

	# Check if hovering over another row tile
	_check_hover_target()

## Check which row tile we're hovering over (vertical detection only)
func _check_hover_target() -> void:
	var new_target = null
	var mouse_pos = get_global_mouse_position()

	# Get parent (should be PuzzleGrid)
	var grid = get_parent()
	if grid:
		for child in grid.get_children():
			if child != self and child is Control:
				# Only consider rows that are draggable (not in correct position)
				if "is_draggable" in child and !child.is_draggable:
					continue

				# Check vertical overlap only (horizontal is locked)
				var child_rect = Rect2(child.global_position, child.size)

				# More lenient vertical detection - check if mouse Y is within row bounds
				if mouse_pos.y >= child_rect.position.y and mouse_pos.y <= child_rect.position.y + child_rect.size.y:
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
