class_name SpiralPuzzleState
extends Resource

## Spiral puzzle gameplay state

const SpiralRing = preload("res://scripts/spiral_ring.gd")

var level_id: int = 0
var difficulty: String = "easy"
var ring_count: int = 3  # Total number of rings
var rings: Array[SpiralRing] = []  # Array of SpiralRing objects
var active_ring_count: int = 0  # Number of unmerged rings
var rotation_count: int = 0  # Number of rotations made
var hints_used: int = 0  # Hints used this session
var is_solved: bool = false
var puzzle_radius: float = 450.0  # Maximum radius of puzzle in pixels

## Check if puzzle is solved (all rings merged)
func is_puzzle_solved() -> bool:
	# Puzzle is solved when all inner rings have merged into the locked outer ring
	return active_ring_count == 0

## Update physics for all rings
func update_physics(delta: float) -> void:
	for ring in rings:
		if ring != null and not ring.is_locked:
			ring.update_rotation(delta)

## Check and perform ring merging
func check_and_merge_rings() -> bool:
	var any_merged = false

	# Check adjacent rings for merge conditions
	# Note: We iterate and break on first merge to avoid index issues
	for i in range(rings.size() - 1):
		var inner_ring = rings[i]
		var outer_ring = rings[i + 1]

		if inner_ring == null or outer_ring == null:
			continue

		if inner_ring.can_merge_with(outer_ring):
			# Keep outer ring (i+1), expand it inward to encompass inner ring
			outer_ring.inner_radius = inner_ring.inner_radius

			# Merge: average angles/velocities, inherit lock state
			outer_ring.merge_with(inner_ring)

			# Remove inner ring from array
			rings.remove_at(i)
			active_ring_count -= 1
			any_merged = true

			# Play merge sound
			if AudioManager:
				AudioManager.play_sfx("ring_merge")

			# Break and let next frame check again (indices have shifted)
			break

	return any_merged

## Get ring at a specific index
func get_ring_by_index(index: int) -> SpiralRing:
	if index >= 0 and index < rings.size():
		return rings[index]
	return null

## Find which ring a touch position belongs to (returns ring index or -1)
func get_ring_at_position(touch_pos: Vector2, center: Vector2) -> int:
	# Calculate distance from center
	var offset = touch_pos - center
	var distance = offset.length()

	# Find ring based on radial distance (prioritize innermost for overlaps)
	for i in range(rings.size()):
		var ring = rings[i]
		if ring != null and not ring.is_locked:
			if distance >= ring.inner_radius and distance <= ring.outer_radius:
				return i

	return -1

## Set angular velocity for a ring (from flick gesture)
func set_ring_velocity(ring_index: int, velocity: float) -> void:
	var ring = get_ring_by_index(ring_index)
	if ring != null:
		ring.gain_velocity(velocity)
		if not ring.is_locked:
			rotation_count += 1

## Rotate a ring by a specific angle delta (from drag gesture)
func rotate_ring(ring_index: int, angle_delta: float) -> void:
	var ring = get_ring_by_index(ring_index)
	if ring != null and ring.can_rotate():
		ring.current_angle += angle_delta
		ring.current_angle = ring._normalize_angle(ring.current_angle)
		rotation_count += 1

## Get count of rings at correct angles
func get_correct_ring_count() -> int:
	var count = 0
	for ring in rings:
		if ring != null and ring.is_angle_correct():
			count += 1
	return count
