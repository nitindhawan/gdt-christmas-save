extends Control

## Visual node for a spiral puzzle ring
## Handles rendering, rotation, and input

const SpiralRing = preload("res://scripts/spiral_ring.gd")

signal ring_rotated(angle_delta: float)
signal ring_flicked(angular_velocity: float)
signal ring_tapped()

@export var ring_data: SpiralRing = null
@export var source_texture: Texture2D = null
@export var puzzle_center: Vector2 = Vector2.ZERO
@export var is_interactive: bool = true  # False for merged/static rings

var _is_dragging: bool = false
var _drag_start_angle: float = 0.0
var _last_touch_angles: Array[float] = []
var _last_touch_times: Array[float] = []
var _touch_history_size: int = 5

## Called when node enters scene
func _ready() -> void:
	# All rings need STOP to receive _gui_input events
	# We'll filter them manually in _gui_input based on ring bounds
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Debug print
	if ring_data:
		print("SpiralRingNode ready: Ring %d, Radius %.1f-%.1f, Angle %.1f, Interactive: %s" % [
			ring_data.ring_index,
			ring_data.inner_radius,
			ring_data.outer_radius,
			ring_data.current_angle,
			str(is_interactive)
		])

	# Wait a frame for layout to finish, then print actual size
	await get_tree().process_frame
	print("Ring %d: Actual size = %v, Center = %v" % [ring_data.ring_index, size, size / 2.0])

	# Set up custom drawing
	queue_redraw()

## Handle input events
func _gui_input(event: InputEvent) -> void:
	if ring_data == null:
		return

	# First check if the event is within this ring's bounds
	var event_pos: Vector2
	if event is InputEventMouseButton:
		event_pos = event.position
	elif event is InputEventMouseMotion:
		event_pos = event.position
	else:
		return

	# Debug: Print all button press events
	if event is InputEventMouseButton and event.pressed:
		var local_center = size / 2.0
		var offset = event_pos - local_center
		var distance = offset.length()
		print("Ring %d: Mouse click at distance %.1f (ring bounds: %.1f-%.1f)" % [
			ring_data.ring_index,
			distance,
			ring_data.inner_radius,
			ring_data.outer_radius
		])

	# If touch is not within this ring's radial area, don't accept the event
	if not _is_point_in_ring(event_pos):
		return  # Let it pass through to the next ring

	# Don't accept input for merged rings
	if not is_interactive or ring_data.is_merged:
		print("Ring %d: Input ignored (interactive=%s, merged=%s)" % [
			ring_data.ring_index,
			str(is_interactive),
			str(ring_data.is_merged)
		])
		return

	# Accept the event (prevent it from passing through)
	accept_event()

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				_start_drag(mouse_event.position)
			else:
				_end_drag()

	elif event is InputEventMouseMotion:
		if _is_dragging:
			_update_drag(event.position)

## Start dragging interaction
func _start_drag(touch_pos: Vector2) -> void:
	# Bounds already checked in _gui_input
	print("Ring %d: Started dragging at angle %.1f" % [ring_data.ring_index, _get_touch_angle(touch_pos)])
	_is_dragging = true
	_drag_start_angle = _get_touch_angle(touch_pos)

	# Initialize touch history for flick detection
	_last_touch_angles.clear()
	_last_touch_times.clear()
	_last_touch_angles.append(_drag_start_angle)
	_last_touch_times.append(Time.get_ticks_msec() / 1000.0)

	# Play pickup sound
	if AudioManager:
		AudioManager.play_sfx("tile_pickup")

## Update drag rotation
func _update_drag(touch_pos: Vector2) -> void:
	var current_angle = _get_touch_angle(touch_pos)
	var angle_delta = current_angle - _drag_start_angle

	# Normalize angle delta to [-180, 180]
	while angle_delta > 180.0:
		angle_delta -= 360.0
	while angle_delta < -180.0:
		angle_delta += 360.0

	# Apply rotation
	emit_signal("ring_rotated", angle_delta)

	# Update for next frame
	_drag_start_angle = current_angle

	# Record touch history for flick detection
	var current_time = Time.get_ticks_msec() / 1000.0
	_last_touch_angles.append(current_angle)
	_last_touch_times.append(current_time)

	# Keep only recent history
	if _last_touch_angles.size() > _touch_history_size:
		_last_touch_angles.pop_front()
		_last_touch_times.pop_front()

	queue_redraw()

## End dragging and detect flick
func _end_drag() -> void:
	if not _is_dragging:
		return

	_is_dragging = false

	# Calculate flick velocity from touch history
	var angular_velocity = _calculate_flick_velocity()

	if abs(angular_velocity) > 10.0:  # Minimum threshold for flick
		emit_signal("ring_flicked", angular_velocity)
	else:
		# Just a tap or slow drag, stop ring
		emit_signal("ring_flicked", 0.0)

	# Play drop sound
	if AudioManager:
		AudioManager.play_sfx("tile_drop")

	queue_redraw()

## Calculate angular velocity from touch history
func _calculate_flick_velocity() -> float:
	if _last_touch_angles.size() < 2:
		return 0.0

	# Use last few samples to calculate velocity
	var samples_to_use = min(3, _last_touch_angles.size())
	var total_angle_change = 0.0
	var total_time = 0.0

	for i in range(_last_touch_angles.size() - samples_to_use, _last_touch_angles.size() - 1):
		var angle_delta = _last_touch_angles[i + 1] - _last_touch_angles[i]

		# Normalize
		while angle_delta > 180.0:
			angle_delta -= 360.0
		while angle_delta < -180.0:
			angle_delta += 360.0

		total_angle_change += angle_delta
		total_time += _last_touch_times[i + 1] - _last_touch_times[i]

	if total_time > 0:
		return total_angle_change / total_time  # degrees per second
	else:
		return 0.0

## Check if point is within ring bounds
func _is_point_in_ring(point: Vector2) -> bool:
	if ring_data == null:
		return false

	var local_center = size / 2.0
	var offset = point - local_center
	var distance = offset.length()

	return distance >= ring_data.inner_radius and distance <= ring_data.outer_radius

## Get angle of touch position relative to ring center
func _get_touch_angle(touch_pos: Vector2) -> float:
	var local_center = size / 2.0
	var offset = touch_pos - local_center
	return rad_to_deg(atan2(offset.y, offset.x))

## Custom drawing for ring
func _draw() -> void:
	if ring_data == null:
		return

	# Use local center (middle of this Control node)
	var local_center = size / 2.0

	# Draw ring using texture and rotation
	_draw_ring_segment(local_center)

	# Draw border (always draw, even for merged rings)
	_draw_ring_border(local_center)

## Draw the ring segment from source texture
func _draw_ring_segment(center: Vector2) -> void:
	var rotation_rad = deg_to_rad(ring_data.current_angle)

	# Draw ring as a donut shape using textured polygon
	if source_texture:
		_draw_textured_ring(center, rotation_rad)
	else:
		# Fallback: draw colored ring for debugging
		_draw_colored_ring(center)

## Draw a textured ring using the source image
func _draw_textured_ring(center: Vector2, rotation: float) -> void:
	var segments = 64
	var points = PackedVector2Array()
	var uvs = PackedVector2Array()

	var texture_size = source_texture.get_size()
	var tex_center = texture_size / 2.0

	# Build ring polygon with outer and inner vertices
	for i in range(segments + 1):
		var angle = (i / float(segments)) * TAU + rotation
		var cos_a = cos(angle)
		var sin_a = sin(angle)

		# Outer vertex
		var outer_point = center + Vector2(cos_a, sin_a) * ring_data.outer_radius
		points.append(outer_point)

		# UV mapping from center of texture
		var uv_outer = (Vector2(cos_a, sin_a) * ring_data.outer_radius + tex_center) / texture_size
		uvs.append(uv_outer)

	# Draw as textured polygon (simplified - just outer circle for now)
	if points.size() > 2:
		draw_colored_polygon(points, Color.WHITE, uvs, source_texture)

## Draw a solid colored ring for debugging
func _draw_colored_ring(center: Vector2) -> void:
	# Use different colors for each ring for visibility
	var ring_colors = [
		Color(1, 0.3, 0.3, 0.7),  # Red
		Color(0.3, 1, 0.3, 0.7),  # Green
		Color(0.3, 0.3, 1, 0.7),  # Blue
		Color(1, 1, 0.3, 0.7),    # Yellow
		Color(1, 0.3, 1, 0.7),    # Magenta
		Color(0.3, 1, 1, 0.7),    # Cyan
		Color(1, 0.6, 0.3, 0.7),  # Orange
	]

	var color = ring_colors[ring_data.ring_index % ring_colors.size()]

	# Draw outer circle
	draw_circle(center, ring_data.outer_radius, color)

	# Draw inner circle as black to create ring effect
	if ring_data.inner_radius > 0:
		draw_circle(center, ring_data.inner_radius, Color(0.1, 0.05, 0.05, 1))

## Draw border around ring
func _draw_ring_border(center: Vector2) -> void:
	var border_color = Color.WHITE if not ring_data.is_merged else Color.DARK_GRAY
	var border_width = GameConstants.SPIRAL_RING_BORDER_WIDTH

	# Draw outer border
	draw_arc(center, ring_data.outer_radius, 0, TAU, 64, border_color, border_width)

	# Draw inner border
	if ring_data.inner_radius > 0:
		draw_arc(center, ring_data.inner_radius, 0, TAU, 64, border_color, border_width)

	# Debug: Draw ring index at center of ring
	var ring_center_radius = (ring_data.inner_radius + ring_data.outer_radius) / 2.0
	var text_pos = center + Vector2(ring_center_radius, 0)
	draw_string(ThemeDB.fallback_font, text_pos, str(ring_data.ring_index), HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color.YELLOW)

## Update visual rotation (called from parent)
func update_visual() -> void:
	queue_redraw()
