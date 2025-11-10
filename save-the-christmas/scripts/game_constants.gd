extends Node

## Game Constants AutoLoad Singleton
## Contains all constants, enums, and configuration values

# File paths
const LEVELS_DATA_PATH = "res://data/levels.json"
const SAVE_DATA_PATH = "user://save_data.cfg"

# Game settings
const TOTAL_LEVELS = 20
const MAX_STARS_PER_LEVEL = 3
const DEFAULT_HINT_LIMIT = 3

# Puzzle mechanics
const TILE_SWAP_DURATION = 0.3  # seconds
const TILE_SELECTION_SCALE = 1.05
const HINT_ANIMATION_DURATION = 0.5

# Audio settings
const DEFAULT_MUSIC_VOLUME = 0.7
const DEFAULT_SOUND_VOLUME = 0.8

# Level image specifications
const LEVEL_IMAGE_SIZE = 2048  # 2048×2048 pixels
const THUMBNAIL_SIZE = 512  # 512×512 pixels

# Enums
enum Difficulty {
	EASY = 0,
	NORMAL = 1,
	HARD = 2
}

enum PuzzleType {
	RECTANGLE_JIGSAW = 0,
	SPIRAL_TWIST = 1  # Future feature
}

## Helper function: Convert Difficulty enum to string
static func difficulty_to_string(diff: Difficulty) -> String:
	match diff:
		Difficulty.EASY:
			return "easy"
		Difficulty.NORMAL:
			return "normal"
		Difficulty.HARD:
			return "hard"
		_:
			return "easy"

## Helper function: Convert string to Difficulty enum
static func string_to_difficulty(diff_str: String) -> Difficulty:
	match diff_str.to_lower():
		"easy":
			return Difficulty.EASY
		"normal":
			return Difficulty.NORMAL
		"hard":
			return Difficulty.HARD
		_:
			return Difficulty.EASY
