extends Control

## Arrow Node - Visual representation of an arrow in the Arrow Puzzle
## Handles tap input and animations (exit and bounce)

const Arrow = preload("res://scripts/arrow.gd")

signal arrow_tapped(arrow_id: int)

var arrow_data: Arrow
var original_position: Vector2

@onready var evil_cloud: TextureRect = $EvilCloud
@onready var shadow: Panel = $Shadow
@onready var background: Panel = $Background
@onready var arrow_texture: TextureRect = $ArrowTexture


func setup(arrow: Arrow) -> void:
	"""Initialize the arrow node with arrow data"""
	arrow_data = arrow
	original_position = global_position

	# Load and set evil cloud texture (random face from 4x4 grid)
	_setup_evil_cloud()

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


func _setup_evil_cloud() -> void:
	"""Setup evil cloud with random face from sprite sheet"""
	var cloud_texture = load(GameConstants.EVIL_CLOUD_TEXTURE_PATH)
	if not cloud_texture:
		push_error("Failed to load evil cloud texture")
		return

	# Create AtlasTexture to select random face from 4x4 grid
	var atlas = AtlasTexture.new()
	atlas.atlas = cloud_texture

	# Calculate cell size (assuming square faces)
	var texture_size = cloud_texture.get_size()
	var cell_width = texture_size.x / GameConstants.EVIL_CLOUD_GRID_SIZE.x
	var cell_height = texture_size.y / GameConstants.EVIL_CLOUD_GRID_SIZE.y

	# Pick random cell from 16 faces
	var random_index = randi() % (GameConstants.EVIL_CLOUD_GRID_SIZE.x * GameConstants.EVIL_CLOUD_GRID_SIZE.y)
	var grid_x = random_index % GameConstants.EVIL_CLOUD_GRID_SIZE.x
	var grid_y = random_index / GameConstants.EVIL_CLOUD_GRID_SIZE.x

	# Set atlas region
	atlas.region = Rect2(
		grid_x * cell_width,
		grid_y * cell_height,
		cell_width,
		cell_height
	)

	# Apply texture
	evil_cloud.texture = atlas


func animate_exit() -> void:
	"""Animate arrow and cloud moving off-screen in arrow's direction"""
	if arrow_data:
		arrow_data.is_animating = true

	# Calculate exit movement direction (arrow moves in its pointing direction)
	var exit_direction = arrow_data.get_direction_vector()

	# Move off-screen - distance should be large enough to fully exit viewport
	var exit_distance = 2000.0  # pixels
	var exit_offset = Vector2(exit_direction.x * exit_distance, exit_direction.y * exit_distance)
	var target_position = global_position + exit_offset

	# Animate movement off-screen with fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)

	# Move arrow and cloud together (entire Control node moves)
	tween.tween_property(self, "global_position", target_position, 0.5)
	# Fade out as it moves
	tween.tween_property(self, "modulate:a", 0.0, 0.4)

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
