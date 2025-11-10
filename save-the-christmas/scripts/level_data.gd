class_name LevelData
extends Resource

## Level definition loaded from levels.json

@export var level_id: int = 0
@export var name: String = ""
@export var image_path: String = ""
@export var thumbnail_path: String = ""
@export var puzzle_type: String = "rectangle_jigsaw"
@export var difficulty_configs: Dictionary = {}  # {easy: {}, normal: {}, hard: {}}
@export var hint_limit: int = 3
@export var tags: Array[String] = []

# Runtime computed properties
var image_texture: Texture2D = null
var thumbnail_texture: Texture2D = null

## Get difficulty configuration for a specific difficulty
func get_difficulty_config(difficulty: String) -> Dictionary:
	return difficulty_configs.get(difficulty.to_lower(), {})

## Get tile count for a specific difficulty
func get_tile_count(difficulty: String) -> int:
	var config = get_difficulty_config(difficulty)
	return config.get("tile_count", 6)

## Get grid size for a specific difficulty (returns Vector2i with columns, rows)
func get_grid_size(difficulty: String) -> Vector2i:
	var config = get_difficulty_config(difficulty)
	var rows = config.get("rows", 2)
	var columns = config.get("columns", 3)
	return Vector2i(columns, rows)
