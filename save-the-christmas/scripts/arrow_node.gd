extends Control

## Arrow Node - Visual representation of an arrow in the Arrow Puzzle
## Handles tap input and animations (exit and bounce)

const Arrow = preload("res://scripts/arrow.gd")

signal arrow_tapped(arrow_id: int)

var arrow_data: Arrow
var original_position: Vector2

@onready var shadow: Panel = $Shadow
@onready var background: Panel = $Background
@onready var arrow_texture: TextureRect = $ArrowTexture


func setup(arrow: Arrow) -> void:
	"""Initialize the arrow node with arrow data"""
	arrow_data = arrow
	original_position = global_position

	# Load and set arrow texture
	var texture = load(GameConstants.ARROW_TEXTURE_PATH)
	if texture:
		arrow_texture.texture = texture

	# Wait for layout to get proper size
	await get_tree().process_frame

	# Set pivot to center of the TextureRect for proper rotation
	arrow_texture.pivot_offset = arrow_texture.size / 2.0

	# Rotate arrow based on direction
	arrow_texture.rotation_degrees = arrow.get_rotation_degrees()

	# Set name for debugging
	name = "Arrow_" + str(arrow.arrow_id)


func animate_exit() -> void:
	"""Animate arrow exiting the puzzle (immediate fade out)"""
	if arrow_data:
		arrow_data.is_animating = true

	# Fade out quickly
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, GameConstants.ARROW_EXIT_DURATION)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), GameConstants.ARROW_EXIT_DURATION)

	await tween.finished

	# Remove from scene tree
	queue_free()


func animate_bounce() -> void:
	"""Animate arrow bouncing back when blocked"""
	if arrow_data:
		arrow_data.is_animating = true

	# Calculate bounce direction (opposite of arrow direction)
	var bounce_dir = -arrow_data.get_direction_vector()
	var bounce_distance = 20.0  # pixels to bounce
	var bounce_offset = Vector2(bounce_dir.x * bounce_distance, bounce_dir.y * bounce_distance)

	# Bounce animation: move away and back
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# Move away
	tween.tween_property(self, "global_position", original_position + bounce_offset, GameConstants.ARROW_BOUNCE_DURATION * 0.4)

	# Move back with bounce ease
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", original_position, GameConstants.ARROW_BOUNCE_DURATION * 0.6)

	await tween.finished

	if arrow_data:
		arrow_data.is_animating = false


func _on_gui_input(event: InputEvent) -> void:
	"""Handle tap input on the arrow"""
	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_tap()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_tap()


func _handle_tap() -> void:
	"""Process arrow tap"""
	if arrow_data == null:
		return

	# Ignore taps if arrow already exited or is animating
	if arrow_data.has_exited or arrow_data.is_animating:
		return

	# Emit signal to gameplay screen
	arrow_tapped.emit(arrow_data.arrow_id)
