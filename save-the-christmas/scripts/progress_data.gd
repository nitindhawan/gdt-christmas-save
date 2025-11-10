class_name ProgressData
extends Resource

## Player progression state

var current_level: int = 1
var highest_level_unlocked: int = 1
var stars: Dictionary = {}  # {level_id: {easy: bool, normal: bool, hard: bool}}

## Check if a level is unlocked
func is_level_unlocked(level_id: int) -> bool:
	return level_id <= highest_level_unlocked

## Check if a specific difficulty is unlocked for a level
func is_difficulty_unlocked(level_id: int, difficulty: String) -> bool:
	if not is_level_unlocked(level_id):
		return false

	match difficulty.to_lower():
		"easy":
			return true  # Easy always unlocked if level unlocked
		"normal":
			return get_star(level_id, "easy")  # Unlocked after Easy completion
		"hard":
			return get_star(level_id, "normal")  # Unlocked after Normal completion
		_:
			return false

## Get star status for a level and difficulty
func get_star(level_id: int, difficulty: String) -> bool:
	if not stars.has(level_id):
		return false
	return stars[level_id].get(difficulty.to_lower(), false)

## Set star status for a level and difficulty
func set_star(level_id: int, difficulty: String, earned: bool) -> void:
	if not stars.has(level_id):
		stars[level_id] = {"easy": false, "normal": false, "hard": false}

	stars[level_id][difficulty.to_lower()] = earned

## Get star count for a specific level (0-3)
func get_star_count(level_id: int) -> int:
	if not stars.has(level_id):
		return 0

	var count = 0
	if stars[level_id].get("easy", false):
		count += 1
	if stars[level_id].get("normal", false):
		count += 1
	if stars[level_id].get("hard", false):
		count += 1
	return count

## Get total stars earned across all levels
func get_total_stars() -> int:
	var total = 0
	for level_id in stars.keys():
		total += get_star_count(level_id)
	return total

## Unlock next level
func unlock_next_level() -> void:
	if current_level < GameConstants.TOTAL_LEVELS:
		var next_level = current_level + 1
		if next_level > highest_level_unlocked:
			highest_level_unlocked = next_level
