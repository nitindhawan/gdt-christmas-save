extends Node

## Level Manager AutoLoad Singleton
## Loads and manages level data from levels.json, handles image caching

var levels: Array = []  # Array of LevelData objects
var level_textures: Dictionary = {}  # Cache for loaded level images
var thumbnail_textures: Dictionary = {}  # Cache for loaded thumbnails
var total_levels: int = 100  # Total number of levels (can be higher than levels.size())

var _levels_loaded: bool = false

## Load all levels from levels.json
func load_levels() -> bool:
	if _levels_loaded:
		print("Levels already loaded")
		return true

	var file = FileAccess.open(GameConstants.LEVELS_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open levels.json: " + str(FileAccess.get_open_error()))
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("Failed to parse levels.json: " + json.get_error_message())
		return false

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Invalid levels.json format: root is not a dictionary")
		return false

	if not data.has("levels"):
		push_error("Invalid levels.json format: missing 'levels' array")
		return false

	var levels_array = data["levels"]
	if typeof(levels_array) != TYPE_ARRAY:
		push_error("Invalid levels.json format: 'levels' is not an array")
		return false

	# Read total_levels from JSON (defaults to 100 if not specified)
	total_levels = data.get("total_levels", 100)

	# Parse each level
	levels.clear()
	for level_dict in levels_array:
		var level_data = _parse_level_data(level_dict)
		if level_data != null:
			levels.append(level_data)

	_levels_loaded = true
	print("Loaded %d levels from JSON, total_levels set to %d" % [levels.size(), total_levels])
	return true

## Parse a level dictionary into a LevelData-like dictionary
func _parse_level_data(level_dict: Dictionary) -> Dictionary:
	if not level_dict.has("level_id"):
		push_error("Level missing 'level_id' field")
		return {}

	var level_data = {
		"level_id": level_dict.get("level_id", 0),
		"name": level_dict.get("name", "Unnamed Level"),
		"image_path": level_dict.get("image_path", ""),
		"thumbnail_path": level_dict.get("thumbnail_path", ""),
		"puzzle_type": level_dict.get("puzzle_type", "rectangle_jigsaw"),
		"difficulty_configs": level_dict.get("difficulty_configs", {}),
		"hint_limit": level_dict.get("hint_limit", GameConstants.DEFAULT_HINT_LIMIT),
		"tags": level_dict.get("tags", [])
	}

	return level_data

## Generate a dynamic level (cycles through 3 images, 3-way puzzle type rotation)
func _generate_dynamic_level(level_id: int) -> Dictionary:
	# Cycle through 3 images
	var image_index = ((level_id - 1) % 3) + 1  # 1, 2, or 3

	# Determine puzzle type: 3-way rotation
	# Level % 3 == 1 -> Spiral Twist
	# Level % 3 == 2 -> Rectangle Jigsaw
	# Level % 3 == 0 -> Arrow Puzzle
	var puzzle_type: String
	var mod_result = level_id % 3
	if mod_result == 1:
		puzzle_type = "spiral_twist"
	elif mod_result == 2:
		puzzle_type = "rectangle_jigsaw"
	else:  # mod_result == 0
		puzzle_type = "arrow_puzzle"

	# Generate difficulty configs based on puzzle type
	var difficulty_configs = {}
	if puzzle_type == "spiral_twist":
		# Spiral puzzle configs
		difficulty_configs = {
			"easy": {
				"ring_count": GameConstants.SPIRAL_RINGS_EASY
			},
			"normal": {
				"ring_count": GameConstants.SPIRAL_RINGS_NORMAL
			},
			"hard": {
				"ring_count": GameConstants.SPIRAL_RINGS_HARD
			}
		}
	elif puzzle_type == "arrow_puzzle":
		# Arrow puzzle configs
		difficulty_configs = {
			"easy": {
				"grid_size": GameConstants.ARROW_GRID_EASY
			},
			"normal": {
				"grid_size": GameConstants.ARROW_GRID_NORMAL
			},
			"hard": {
				"grid_size": GameConstants.ARROW_GRID_HARD
			}
		}
	else:
		# Rectangle puzzle configs
		difficulty_configs = {
			"easy": {
				"rows": 2,
				"columns": 3,
				"tile_count": 6
			},
			"normal": {
				"rows": 3,
				"columns": 4,
				"tile_count": 12
			},
			"hard": {
				"rows": 5,
				"columns": 6,
				"tile_count": 30
			}
		}

	# Build level data
	var level_data = {
		"level_id": level_id,
		"name": "Level %d" % level_id,
		"image_path": "res://assets/levels/level_0%d.png" % image_index,
		"thumbnail_path": "res://assets/levels/thumbnails/level_0%d_thumb.png" % image_index,
		"puzzle_type": puzzle_type,
		"difficulty_configs": difficulty_configs,
		"hint_limit": 0,  # Hints removed
		"tags": []
	}

	print("Generated dynamic level %d: Type=%s, Image=%d" % [level_id, puzzle_type, image_index])

	return level_data

## Get level data by level ID (now generates levels dynamically)
func get_level(level_id: int) -> Dictionary:
	# Check if level exists in loaded levels (from JSON)
	for level in levels:
		if level["level_id"] == level_id:
			return level

	# Generate level dynamically if not in JSON
	# This allows infinite levels by cycling through 3 images
	return _generate_dynamic_level(level_id)

## Get level texture (loads and caches if not already loaded)
func get_level_texture(level_id: int) -> Texture2D:
	if level_textures.has(level_id):
		return level_textures[level_id]

	var level = get_level(level_id)
	if level.is_empty():
		return null

	var texture = load(level["image_path"]) as Texture2D
	if texture != null:
		level_textures[level_id] = texture
		print("Loaded level texture for level ", level_id)
	else:
		push_error("Failed to load level texture: " + level["image_path"])

	return texture

## Get thumbnail texture (loads and caches if not already loaded)
func get_thumbnail_texture(level_id: int) -> Texture2D:
	if thumbnail_textures.has(level_id):
		return thumbnail_textures[level_id]

	var level = get_level(level_id)
	if level.is_empty():
		return null

	var texture = load(level["thumbnail_path"]) as Texture2D
	if texture != null:
		thumbnail_textures[level_id] = texture
		print("Loaded thumbnail texture for level ", level_id)
	else:
		push_error("Failed to load thumbnail texture: " + level["thumbnail_path"])

	return texture

## Get difficulty configuration for a level
func get_difficulty_config(level_id: int, difficulty: String) -> Dictionary:
	var level = get_level(level_id)
	if level.is_empty():
		return {}

	var configs = level.get("difficulty_configs", {})
	return configs.get(difficulty.to_lower(), {})

## Get grid size for a level and difficulty
func get_grid_size(level_id: int, difficulty: String) -> Vector2i:
	var config = get_difficulty_config(level_id, difficulty)
	if config.is_empty():
		return Vector2i(2, 3)  # Default to easy

	var rows = config.get("rows", 2)
	var columns = config.get("columns", 3)
	return Vector2i(columns, rows)  # Return as (width, height)

## Get tile count for a level and difficulty
func get_tile_count(level_id: int, difficulty: String) -> int:
	var config = get_difficulty_config(level_id, difficulty)
	return config.get("tile_count", 6)

## Get total number of levels
func get_total_levels() -> int:
	return total_levels

## Unload a level texture from cache to free memory
func unload_level_texture(level_id: int) -> void:
	if level_textures.has(level_id):
		level_textures.erase(level_id)
		print("Unloaded level texture for level ", level_id)

## Unload all cached textures
func clear_texture_cache() -> void:
	level_textures.clear()
	thumbnail_textures.clear()
	print("Cleared all texture caches")
