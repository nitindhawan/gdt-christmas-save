extends MeshInstance2D

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
	# Debug print
	if ring_data:
		print("SpiralRingNode ready: Ring %d, Radius %.1f-%.1f, Angle %.1f, Locked: %s" % [
			ring_data.ring_index,
			ring_data.inner_radius,
			ring_data.outer_radius,
			ring_data.current_angle,
			str(ring_data.is_locked)
		])

	# Generate mesh once (not every frame!)
	if ring_data and source_texture:
		mesh = _create_ring_mesh(ring_data.inner_radius, ring_data.outer_radius, source_texture)
		texture = source_texture  # Set texture property on MeshInstance2D

		# Create border rings (optional visual enhancement)
		_create_border_rings()

		# Set initial rotation
		update_visual()

## Create ring mesh (called once in _ready)
func _create_ring_mesh(inner_radius: float, outer_radius: float, texture_resource: Texture2D) -> ArrayMesh:
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	var vertices = PackedVector2Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()

	var segments = 128
	var tex_center = texture_resource.get_size() / 2.0
	var tex_size = texture_resource.get_size()

	# Calculate scale factor: texture space vs screen space
	# Texture radius = image_height / 2, Screen radius = max_radius (480px)
	# Scale factor = texture_radius / screen_radius
	var texture_radius = tex_size.y / 2.0  # Assuming square texture
	var screen_max_radius = 480.0  # Matches puzzle_manager.gd max_radius
	var uv_scale = texture_radius / screen_max_radius

	# Generate vertices and UVs (ONCE, not every frame!)
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var cos_a = cos(angle)
		var sin_a = sin(angle)

		# Outer vertex (geometry space, centered at origin)
		vertices.append(Vector2(cos_a, sin_a) * outer_radius)
		# Inner vertex
		vertices.append(Vector2(cos_a, sin_a) * inner_radius)

		# UV coordinates (texture space, scaled from screen space)
		var uv_outer_radius = outer_radius * uv_scale
		var uv_inner_radius = inner_radius * uv_scale
		var uv_outer = (Vector2(cos_a, sin_a) * uv_outer_radius + tex_center) / tex_size
		var uv_inner = (Vector2(cos_a, sin_a) * uv_inner_radius + tex_center) / tex_size
		uvs.append(uv_outer)
		uvs.append(uv_inner)

	# Generate triangle indices (donut shape = 2 triangles per segment)
	for i in range(segments):
		var outer_current = i * 2
		var inner_current = i * 2 + 1
		var outer_next = ((i + 1) % segments) * 2
		var inner_next = ((i + 1) % segments) * 2 + 1

		# Quad = 2 triangles
		indices.append_array([outer_current, inner_current, outer_next])
		indices.append_array([inner_current, inner_next, outer_next])

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return new_mesh

## Create border rings (Line2D children)
func _create_border_rings() -> void:
	# Outer border (white for unlocked rings, dark gray for locked corner ring)
	var outer_border = Line2D.new()
	outer_border.width = GameConstants.SPIRAL_RING_BORDER_WIDTH
	outer_border.default_color = Color.WHITE if not ring_data.is_locked else Color.DARK_GRAY
	outer_border.closed = true

	# Generate circle points
	for i in range(65):  # 64 segments for smooth border
		var angle = (i / 64.0) * TAU
		outer_border.add_point(Vector2(cos(angle), sin(angle)) * ring_data.outer_radius)

	add_child(outer_border)

	# Inner border (if not innermost ring)
	if ring_data.inner_radius > 0:
		var inner_border = Line2D.new()
		inner_border.width = GameConstants.SPIRAL_RING_BORDER_WIDTH
		inner_border.default_color = Color.WHITE if not ring_data.is_locked else Color.DARK_GRAY
		inner_border.closed = true

		for i in range(65):
			var angle = (i / 64.0) * TAU
			inner_border.add_point(Vector2(cos(angle), sin(angle)) * ring_data.inner_radius)

		add_child(inner_border)

## Regenerate mesh after ring data changes (e.g., after merge)
func regenerate_mesh() -> void:
	if ring_data and source_texture:
		mesh = _create_ring_mesh(ring_data.inner_radius, ring_data.outer_radius, source_texture)
		texture = source_texture

		# Remove old border children and recreate
		for child in get_children():
			if child is Line2D:
				child.queue_free()

		_create_border_rings()
		update_visual()

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

	# Play ring drag start sound
	if AudioManager:
		AudioManager.play_sfx("ring_drag_start")

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

	# Play ring drag stop sound (not mapped, silent for now)
	if AudioManager:
		AudioManager.play_sfx("ring_drag_stop")

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

	# Point is already in rings_container coordinate space
	# Ring's position is the center of the ring
	var offset = point - position
	var distance = offset.length()
	var in_bounds = distance >= ring_data.inner_radius and distance <= ring_data.outer_radius

	return in_bounds

## Get angle of touch position relative to ring center
func _get_touch_angle(touch_pos: Vector2) -> float:
	# touch_pos is already in rings_container coordinate space
	# Ring's position is the center
	var offset = touch_pos - position
	return rad_to_deg(atan2(offset.y, offset.x))

## Update visual rotation (called from parent)
func update_visual() -> void:
	# Simple rotation update - rotate the mesh, not the UVs!
	rotation = deg_to_rad(ring_data.current_angle)
