extends Node

## Progress Manager AutoLoad Singleton
## Handles save/load system, star tracking, and level unlock logic

var current_level: int = 1
var highest_level_unlocked: int = 1
var stars: Dictionary = {}  # {level_id: {easy: bool, normal: bool, hard: bool}}

# Settings
var sound_enabled: bool = true
var music_enabled: bool = true
var vibrations_enabled: bool = true
var music_volume: float = GameConstants.DEFAULT_MUSIC_VOLUME
var sound_volume: float = GameConstants.DEFAULT_SOUND_VOLUME

# Statistics
var total_playtime_seconds: int = 0
var total_swaps_made: int = 0
var total_hints_used: int = 0

var _save_file: ConfigFile = ConfigFile.new()

func _ready() -> void:
	load_save_data()

## Load save data from disk
func load_save_data() -> void:
	var err = _save_file.load(GameConstants.SAVE_DATA_PATH)

	if err != OK:
		# No save file exists, create default save
		print("No save file found, creating default save data")
		_create_default_save()
		return

	# Load metadata
	var version = _save_file.get_value("metadata", "version", "1.0")
	print("Loading save data version: ", version)

	# Load progress
	current_level = _save_file.get_value("progress", "current_level", 1)
	highest_level_unlocked = _save_file.get_value("progress", "highest_level_unlocked", 1)

	# Load stars
	stars.clear()
	for level_id in range(1, GameConstants.TOTAL_LEVELS + 1):
		stars[level_id] = {
			"easy": _save_file.get_value("stars", "level_%d_easy" % level_id, false),
			"normal": _save_file.get_value("stars", "level_%d_normal" % level_id, false),
			"hard": _save_file.get_value("stars", "level_%d_hard" % level_id, false)
		}

	# Load settings
	sound_enabled = _save_file.get_value("settings", "sound_enabled", true)
	music_enabled = _save_file.get_value("settings", "music_enabled", true)
	vibrations_enabled = _save_file.get_value("settings", "vibrations_enabled", true)
	music_volume = _save_file.get_value("settings", "music_volume", GameConstants.DEFAULT_MUSIC_VOLUME)
	sound_volume = _save_file.get_value("settings", "sound_volume", GameConstants.DEFAULT_SOUND_VOLUME)

	# Load statistics
	total_playtime_seconds = _save_file.get_value("statistics", "total_playtime_seconds", 0)
	total_swaps_made = _save_file.get_value("statistics", "total_swaps_made", 0)
	total_hints_used = _save_file.get_value("statistics", "total_hints_used", 0)

	print("Save data loaded successfully")

## Create default save data
func _create_default_save() -> void:
	current_level = 1
	highest_level_unlocked = 1
	stars.clear()
	for level_id in range(1, GameConstants.TOTAL_LEVELS + 1):
		stars[level_id] = {"easy": false, "normal": false, "hard": false}

	sound_enabled = true
	music_enabled = true
	vibrations_enabled = true
	music_volume = GameConstants.DEFAULT_MUSIC_VOLUME
	sound_volume = GameConstants.DEFAULT_SOUND_VOLUME

	total_playtime_seconds = 0
	total_swaps_made = 0
	total_hints_used = 0

	save_progress()

## Save progress to disk
func save_progress() -> void:
	# Metadata
	_save_file.set_value("metadata", "version", "1.0")
	_save_file.set_value("metadata", "last_played_timestamp", Time.get_unix_time_from_system())

	# Progress
	_save_file.set_value("progress", "current_level", current_level)
	_save_file.set_value("progress", "highest_level_unlocked", highest_level_unlocked)

	# Stars
	for level_id in stars.keys():
		_save_file.set_value("stars", "level_%d_easy" % level_id, stars[level_id]["easy"])
		_save_file.set_value("stars", "level_%d_normal" % level_id, stars[level_id]["normal"])
		_save_file.set_value("stars", "level_%d_hard" % level_id, stars[level_id]["hard"])

	# Settings
	_save_file.set_value("settings", "sound_enabled", sound_enabled)
	_save_file.set_value("settings", "music_enabled", music_enabled)
	_save_file.set_value("settings", "vibrations_enabled", vibrations_enabled)
	_save_file.set_value("settings", "music_volume", music_volume)
	_save_file.set_value("settings", "sound_volume", sound_volume)

	# Statistics
	_save_file.set_value("statistics", "total_playtime_seconds", total_playtime_seconds)
	_save_file.set_value("statistics", "total_swaps_made", total_swaps_made)
	_save_file.set_value("statistics", "total_hints_used", total_hints_used)
	_save_file.set_value("statistics", "total_stars_earned", get_total_stars())

	var err = _save_file.save(GameConstants.SAVE_DATA_PATH)
	if err != OK:
		push_error("Failed to save progress: " + str(err))
	else:
		print("Progress saved successfully")

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

	# If earned, update higher star levels if completing a higher difficulty
	if earned:
		match difficulty.to_lower():
			"hard":
				stars[level_id]["normal"] = true
				stars[level_id]["easy"] = true
			"normal":
				stars[level_id]["easy"] = true

## Get star count for a specific level (0-3)
func get_star_count(level_id: int) -> int:
	if not stars.has(level_id):
		return 0

	var count = 0
	if stars[level_id]["easy"]:
		count += 1
	if stars[level_id]["normal"]:
		count += 1
	if stars[level_id]["hard"]:
		count += 1
	return count

## Get total stars earned across all levels
func get_total_stars() -> int:
	var total = 0
	for level_id in stars.keys():
		total += get_star_count(level_id)
	return total

## Unlock next level based on progression rules
func unlock_next_level() -> void:
	if current_level < GameConstants.TOTAL_LEVELS:
		var next_level = current_level + 1
		if next_level > highest_level_unlocked:
			highest_level_unlocked = next_level
			print("Unlocked level: ", next_level)

## Reset all progress (for testing or user request)
func reset_progress() -> void:
	_create_default_save()
	print("Progress reset to default")
