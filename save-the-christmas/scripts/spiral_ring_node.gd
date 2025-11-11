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

var _is_dragging: bool = false
var _drag_start_angle: float = 0.0
var _last_touch_angles: Array[float] = []
var _last_touch_times: Array[float] = []
var _touch_history_size: int = 5

## Called when node enters scene
func _ready() -> void:
	# Rings don't handle input individually - parent handles it
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Debug print
	if ring_data:
		print("SpiralRingNode ready: Ring %d, Radius %.1f-%.1f, Angle %.1f, Locked: %s" % [
			ring_data.ring_index,
			ring_data.inner_radius,
			ring_data.outer_radius,
			ring_data.current_angle,
			str(ring_data.is_locked)
		])

	# Wait a frame for layout to finish, then print actual size
	await get_tree().process_frame
	print("Ring %d: Actual size = %v, Center = %v, Position = %v" % [ring_data.ring_index, size, size / 2.0, global_position])
	print("Ring %d: Anchors = L:%.2f T:%.2f R:%.2f B:%.2f" % [ring_data.ring_index, anchor_left, anchor_top, anchor_right, anchor_bottom])
	print("Ring %d: Mouse filter = %d, Visible = %s, is_locked = %s" % [ring_data.ring_index, mouse_filter, str(visible), str(ring_data.is_locked)])

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

	# Check if within this ring's radial area first
	var in_bounds = _is_point_in_ring(event_pos)

	# Debug: Print all button press events
	if event is InputEventMouseButton and event.pressed:
		print("Ring %d: GOT MOUSE EVENT! Size=%v, Event pos=%v" % [
			ring_data.ring_index,
			size,
			event_pos
		])
		var local_center = size / 2.0
		var offset = event_pos - local_center
		var distance = offset.length()
		print("Ring %d: Click distance %.1f, bounds [%.1f-%.1f], in_bounds=%s" % [
			ring_data.ring_index,
			distance,
			ring_data.inner_radius,
			ring_data.outer_radius,
			str(in_bounds)
		])

	# If touch is not within this ring's radial area, don't accept the event
	if not in_bounds:
		return  # Let it pass through to the next ring

	# Don't accept input for locked rings
	if ring_data.is_locked:
		print("Ring %d: Input ignored (locked=%s)" % [
			ring_data.ring_index,
			str(ring_data.is_locked)
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

## Public method for external drag start (called by gameplay_screen)
func start_drag_external(touch_pos: Vector2) -> void:
	_is_dragging = true
	_start_drag(touch_pos)

## Public method for external drag update (called by gameplay_screen)
func update_drag_external(touch_pos: Vector2) -> float:
	var current_angle = _get_touch_angle(touch_pos)
	var angle_delta = current_angle - _drag_start_angle

	# Normalize angle delta to [-180, 180]
	while angle_delta > 180.0:
		angle_delta -= 360.0
	while angle_delta < -180.0:
		angle_delta += 360.0

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
	return angle_delta

## Public method for external drag end (called by gameplay_screen)
func end_drag_external() -> float:
	_is_dragging = false
	var angular_velocity = _calculate_flick_velocity()
	if abs(angular_velocity) < 10.0:
		angular_velocity = 0.0
	queue_redraw()
	return angular_velocity

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
	var in_bounds = distance >= ring_data.inner_radius and distance <= ring_data.outer_radius

	return in_bounds

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
	if not source_texture:
		return

	var rotation_rad = deg_to_rad(ring_data.current_angle)

	# Draw ring as a donut shape using textured polygon
	var segments = 128  # More segments for smoother rings
	var outer_points = PackedVector2Array()
	var inner_points = PackedVector2Array()
	var outer_uvs = PackedVector2Array()

	var texture_size = source_texture.get_size()
	var tex_center = texture_size / 2.0

	# Build ring polygon with both outer and inner vertices to create donut shape
	for i in range(segments + 1):
		# Geometry angle (fixed positions forming a circle)
		var geom_angle = (i / float(segments)) * TAU
		var cos_geom = cos(geom_angle)
		var sin_geom = sin(geom_angle)

		# Outer vertex (fixed position)
		var outer_point = center + Vector2(cos_geom, sin_geom) * ring_data.outer_radius
		outer_points.append(outer_point)

		# UV angle (rotated to show different part of texture)
		var uv_angle = geom_angle + rotation_rad
		var cos_uv = cos(uv_angle)
		var sin_uv = sin(uv_angle)

		# UV mapping for outer vertex (rotated texture coordinates)
		var uv_outer = (Vector2(cos_uv, sin_uv) * ring_data.outer_radius + tex_center) / texture_size
		outer_uvs.append(uv_outer)

		# Inner vertex (fixed position)
		var inner_point = center + Vector2(cos_geom, sin_geom) * ring_data.inner_radius
		inner_points.append(inner_point)

	# Draw ring as individual triangles to form the donut shape
	for i in range(segments):
		# Geometry angles (fixed)
		var geom_angle_current = (i / float(segments)) * TAU
		var geom_angle_next = ((i + 1) / float(segments)) * TAU

		# UV angles (rotated)
		var uv_angle_current = geom_angle_current + rotation_rad
		var uv_angle_next = geom_angle_next + rotation_rad

		# Calculate UV coordinates for inner vertices (rotated)
		var uv_inner_current = (Vector2(cos(uv_angle_current), sin(uv_angle_current)) * ring_data.inner_radius + tex_center) / texture_size
		var uv_inner_next = (Vector2(cos(uv_angle_next), sin(uv_angle_next)) * ring_data.inner_radius + tex_center) / texture_size

		# Triangle 1: outer[i], inner[i], outer[i+1]
		var tri1_points = PackedVector2Array([
			outer_points[i],
			inner_points[i],
			outer_points[i + 1]
		])
		var tri1_uvs = PackedVector2Array([
			outer_uvs[i],
			uv_inner_current,
			outer_uvs[i + 1]
		])
		draw_colored_polygon(tri1_points, Color.WHITE, tri1_uvs, source_texture)

		# Triangle 2: inner[i], inner[i+1], outer[i+1]
		var tri2_points = PackedVector2Array([
			inner_points[i],
			inner_points[i + 1],
			outer_points[i + 1]
		])
		var tri2_uvs = PackedVector2Array([
			uv_inner_current,
			uv_inner_next,
			outer_uvs[i + 1]
		])
		draw_colored_polygon(tri2_points, Color.WHITE, tri2_uvs, source_texture)

## Draw border around ring
func _draw_ring_border(center: Vector2) -> void:
	var border_color = Color.WHITE if not ring_data.is_locked else Color.DARK_GRAY
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
