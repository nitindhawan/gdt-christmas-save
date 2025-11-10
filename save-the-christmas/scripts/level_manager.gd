extends Node

## Level Manager AutoLoad Singleton
## Loads and manages level data from levels.json, handles image caching

var levels: Array = []  # Array of LevelData objects
var level_textures: Dictionary = {}  # Cache for loaded level images
var thumbnail_textures: Dictionary = {}  # Cache for loaded thumbnails

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

	# Parse each level
	levels.clear()
	for level_dict in levels_array:
		var level_data = _parse_level_data(level_dict)
		if level_data != null:
			levels.append(level_data)

	_levels_loaded = true
	print("Loaded ", levels.size(), " levels successfully")
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

## Get level data by level ID
func get_level(level_id: int) -> Dictionary:
	for level in levels:
		if level["level_id"] == level_id:
			return level
	push_error("Level not found: " + str(level_id))
	return {}

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
	return levels.size()

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
