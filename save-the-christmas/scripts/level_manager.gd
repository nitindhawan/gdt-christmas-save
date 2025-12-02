extends Node

## Level Manager AutoLoad Singleton
## Loads and manages level data from levels.json, handles image caching

var level_textures: Dictionary = {}  # Cache for loaded level images
var thumbnail_textures: Dictionary = {}  # Cache for loaded thumbnails

## Load all levels (now bypassing levels.json)
func load_levels() -> bool:
	print("LevelManager initialized (bypassing levels.json, using puzzle_01-25.png)")
	return true

## Generate level data dynamically based on level ID
func _generate_dynamic_level(level_id: int) -> Dictionary:
	# Validate level_id range
	if level_id < 1 or level_id > GameConstants.TOTAL_LEVELS:
		push_error("Invalid level_id: %d (valid range: 1-%d)" % [level_id, GameConstants.TOTAL_LEVELS])
		return {}

	# Determine puzzle type: 4-way rotation
	# Level % 4 == 1 -> Spiral Twist
	# Level % 4 == 2 -> Tile Puzzle
	# Level % 4 == 3 -> Arrow Puzzle
	# Level % 4 == 0 -> Row Tile Puzzle
	var puzzle_type: String
	var mod_result = level_id % 4
	if mod_result == 1:
		puzzle_type = "spiral_twist"
	elif mod_result == 2:
		puzzle_type = "tile_puzzle"
	elif mod_result == 3:
		puzzle_type = "arrow_puzzle"
	else:  # mod_result == 0
		puzzle_type = "row_tile_puzzle"

	# Generate difficulty configs based on puzzle type
	var difficulty_configs = {}
	if puzzle_type == "spiral_twist":
		# Spiral puzzle configs (only Easy and Hard)
		difficulty_configs = {
			"easy": {
				"ring_count": GameConstants.SPIRAL_RINGS_EASY
			},
			"hard": {
				"ring_count": GameConstants.SPIRAL_RINGS_HARD
			}
		}
	elif puzzle_type == "arrow_puzzle":
		# Arrow puzzle configs (only Easy and Hard)
		difficulty_configs = {
			"easy": {
				"grid_size": GameConstants.ARROW_GRID_EASY
			},
			"hard": {
				"grid_size": GameConstants.ARROW_GRID_HARD
			}
		}
	elif puzzle_type == "row_tile_puzzle":
		# Row tile puzzle configs (only Easy and Hard)
		difficulty_configs = {
			"easy": {
				"row_count": GameConstants.ROW_TILE_ROWS_EASY
			},
			"hard": {
				"row_count": GameConstants.ROW_TILE_ROWS_HARD
			}
		}
	else:
		# Tile puzzle configs (only Easy and Hard)
		difficulty_configs = {
			"easy": {
				"rows": 2,
				"columns": 3,
				"tile_count": 6
			},
			"hard": {
				"rows": 5,
				"columns": 6,
				"tile_count": 30
			}
		}

	# Use puzzle_XX.png naming convention (01-25)
	var image_filename = "puzzle_%02d.png" % level_id
	var thumb_filename = "puzzle_%02d_thumb.png" % level_id

	# Build level data
	var level_data = {
		"level_id": level_id,
		"name": "Level %d" % level_id,
		"image_path": "res://assets/levels/%s" % image_filename,
		"thumbnail_path": "res://assets/levels/thumbnails/%s" % thumb_filename,
		"puzzle_type": puzzle_type,
		"difficulty_configs": difficulty_configs,
		"hint_limit": 0,  # Hints removed
		"tags": []
	}

	return level_data

## Get level data by level ID
func get_level(level_id: int) -> Dictionary:
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
	return GameConstants.TOTAL_LEVELS

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
