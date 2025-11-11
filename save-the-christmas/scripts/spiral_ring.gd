class_name SpiralRing
extends Resource

## Individual spiral puzzle ring

var ring_index: int = 0  # Ring number from center (0 = innermost, increases outward)
var current_angle: float = 0.0  # Current rotation angle in degrees
var correct_angle: float = 0.0  # Solution angle in degrees (usually 0)
var angular_velocity: float = 0.0  # Current rotation speed in degrees/second
var inner_radius: float = 0.0  # Inner radius in pixels (expands when merging)
var outer_radius: float = 0.0  # Outer radius in pixels
var is_locked: bool = false  # Whether this ring is locked (cannot rotate/be dragged)
var merged_ring_ids: Array[int] = []  # IDs of rings merged into this one

## Check if ring is at correct angle (within threshold)
func is_angle_correct(threshold: float = GameConstants.SPIRAL_ROTATION_SNAP_ANGLE) -> bool:
	var angle_diff = abs(_normalize_angle(current_angle - correct_angle))
	return angle_diff <= threshold

## Check if this ring can merge with another ring
func can_merge_with(other_ring: SpiralRing) -> bool:
	# Two locked rings cannot merge
	if is_locked and other_ring.is_locked:
		return false

	# Check if rings are adjacent (ring indices differ by 1)
	if abs(ring_index - other_ring.ring_index) != 1:
		return false

	# Check angle difference
	var angle_diff = abs(_normalize_angle(current_angle - other_ring.current_angle))
	if angle_diff > GameConstants.SPIRAL_MERGE_ANGLE_THRESHOLD:
		return false

	# Check velocity difference
	var velocity_diff = abs(angular_velocity - other_ring.angular_velocity)
	if velocity_diff > GameConstants.SPIRAL_MERGE_VELOCITY_THRESHOLD:
		return false

	return true

## Merge with another ring (this ring absorbs the other)
func merge_with(other_ring: SpiralRing) -> void:
	# Average the angles
	current_angle = (_normalize_angle(current_angle) + _normalize_angle(other_ring.current_angle)) / 2.0

	# Average the velocities
	angular_velocity = (angular_velocity + other_ring.angular_velocity) / 2.0

	# Expand inner radius to encompass the merged ring
	inner_radius = min(inner_radius, other_ring.inner_radius)

	# If merging with a locked ring, this ring becomes locked
	if other_ring.is_locked:
		is_locked = true
		angular_velocity = 0.0

	# Track merged ring IDs
	merged_ring_ids.append(other_ring.ring_index)
	for id in other_ring.merged_ring_ids:
		if id not in merged_ring_ids:
			merged_ring_ids.append(id)

## Apply velocity from flick gesture
func gain_velocity(velocity: float) -> void:
	if is_locked:
		return
	angular_velocity = clamp(velocity,
		-GameConstants.SPIRAL_MAX_ANGULAR_VELOCITY,
		GameConstants.SPIRAL_MAX_ANGULAR_VELOCITY)

## Check if this ring can be rotated by user input
func can_rotate() -> bool:
	return not is_locked

## Update rotation based on velocity and delta time
func update_rotation(delta: float) -> void:
	if is_locked:
		return

	# Apply velocity to angle
	current_angle += angular_velocity * delta
	current_angle = _normalize_angle(current_angle)

	# Apply deceleration (friction)
	if abs(angular_velocity) > GameConstants.SPIRAL_MIN_VELOCITY_THRESHOLD:
		var deceleration = GameConstants.SPIRAL_ANGULAR_DECELERATION * delta
		if angular_velocity > 0:
			angular_velocity = max(0.0, angular_velocity - deceleration)
		else:
			angular_velocity = min(0.0, angular_velocity + deceleration)
	else:
		angular_velocity = 0.0

## Normalize angle to [-180, 180] range
func _normalize_angle(angle: float) -> float:
	while angle > 180.0:
		angle -= 360.0
	while angle < -180.0:
		angle += 360.0
	return angle
