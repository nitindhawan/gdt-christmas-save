extends Node

## Progress Manager AutoLoad Singleton
## Handles save/load system and level unlock logic

var current_level: int = 1
var highest_level_unlocked: int = 1
var completions: Dictionary = {}  # {level_id: {easy: bool, hard: bool}}

# Settings
var sound_enabled: bool = true
var music_enabled: bool = true
var vibrations_enabled: bool = false  # Always disabled for this game
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

	# Load completions
	completions.clear()
	for level_id in range(1, GameConstants.TOTAL_LEVELS + 1):
		completions[level_id] = {
			"easy": _save_file.get_value("completions", "level_%d_easy" % level_id, false),
			"hard": _save_file.get_value("completions", "level_%d_hard" % level_id, false)
		}

	# Load settings
	sound_enabled = _save_file.get_value("settings", "sound_enabled", true)
	music_enabled = _save_file.get_value("settings", "music_enabled", true)
	vibrations_enabled = false  # Always disabled for this game
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
	completions.clear()
	for level_id in range(1, GameConstants.TOTAL_LEVELS + 1):
		completions[level_id] = {"easy": false, "hard": false}

	sound_enabled = true
	music_enabled = true
	vibrations_enabled = false  # Always disabled for this game
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

	# Completions
	for level_id in completions.keys():
		_save_file.set_value("completions", "level_%d_easy" % level_id, completions[level_id]["easy"])
		_save_file.set_value("completions", "level_%d_hard" % level_id, completions[level_id]["hard"])

	# Settings
	_save_file.set_value("settings", "sound_enabled", sound_enabled)
	_save_file.set_value("settings", "music_enabled", music_enabled)
	# Note: vibrations_enabled is always false and not saved
	_save_file.set_value("settings", "music_volume", music_volume)
	_save_file.set_value("settings", "sound_volume", sound_volume)

	# Statistics
	_save_file.set_value("statistics", "total_playtime_seconds", total_playtime_seconds)
	_save_file.set_value("statistics", "total_swaps_made", total_swaps_made)
	_save_file.set_value("statistics", "total_hints_used", total_hints_used)

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
	# Both difficulties always unlocked if level is unlocked
	return is_level_unlocked(level_id)

## Get completion status for a level and difficulty
func get_completion(level_id: int, difficulty: String) -> bool:
	if not completions.has(level_id):
		return false
	return completions[level_id].get(difficulty.to_lower(), false)

## Set completion status for a level and difficulty
func set_completion(level_id: int, difficulty: String, completed: bool) -> void:
	if not completions.has(level_id):
		completions[level_id] = {"easy": false, "hard": false}

	completions[level_id][difficulty.to_lower()] = completed

	# If completing Hard, also mark Easy as complete
	if completed and difficulty.to_lower() == "hard":
		completions[level_id]["easy"] = true

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
