extends Node

## Game Constants AutoLoad Singleton
## Contains all constants, enums, and configuration values

# File paths
const LEVELS_DATA_PATH = "res://data/levels.json"
const SAVE_DATA_PATH = "user://save_data.cfg"

# Game settings
const TOTAL_LEVELS = 25
const MAX_STARS_PER_LEVEL = 3
const DEFAULT_HINT_LIMIT = 3

# Puzzle mechanics - Tile Puzzle
const TILE_SWAP_DURATION = 0.3 # seconds
const TILE_SELECTION_SCALE = 1.05
const HINT_ANIMATION_DURATION = 0.5

# Puzzle mechanics - Spiral Twist
const SPIRAL_RING_BORDER_WIDTH = 4 # pixels
const SPIRAL_MERGE_ANGLE_THRESHOLD = 2.0 # degrees
const SPIRAL_MERGE_VELOCITY_THRESHOLD = 1.0 # degrees per second
const SPIRAL_ANGULAR_DECELERATION = 200.0 # degrees/s² (stops in 2-3 seconds)
const SPIRAL_MAX_ANGULAR_VELOCITY = 720.0 # degrees per second
const SPIRAL_MIN_VELOCITY_THRESHOLD = 1.0 # Stop completely below this
const SPIRAL_ROTATION_SNAP_ANGLE = 1.0 # Snap to correct when within this angle

# Spiral ring counts per difficulty
const SPIRAL_RINGS_EASY = 6
const SPIRAL_RINGS_HARD = 9

# Puzzle mechanics - Arrow Puzzle
const ARROW_BOUNCE_DURATION = 0.2 # Bounce-back animation duration (seconds)
const ARROW_EXIT_DURATION = 0.15 # Fade-out on success (seconds)
const ARROW_GRID_SPACING = 10 # Pixels between arrows

# Arrow grid sizes per difficulty (columns, rows)
const ARROW_GRID_EASY = Vector2i(3, 4) # 12 arrows
const ARROW_GRID_HARD = Vector2i(5, 6) # 30 arrows

# Arrow asset paths
const ARROW_TEXTURE_PATH = "res://assets/ui/up_arrow.png"
const EVIL_CLOUD_TEXTURE_PATH = "res://assets/ui/evil_clouds.png"
const EVIL_CLOUD_GRID_SIZE = Vector2i(4, 4) # 4x4 grid = 16 faces

# Row tile puzzle - row counts per difficulty
const ROW_TILE_ROWS_EASY = 8 # 8 rows
const ROW_TILE_ROWS_HARD = 16 # 16 rows

# Audio settings
const DEFAULT_MUSIC_VOLUME = 0.7
const DEFAULT_SOUND_VOLUME = 0.8

# Visual effects flags
const ENABLE_GAUSSIAN_BLUR = false # Set to true to enable blur shader on popups

# Level image specifications
const LEVEL_IMAGE_SIZE = 1024 # 1024×1024 pixels
const PUZZLE_TEXTURE_WIDTH = 1024 # Width of puzzle textures (should match actual asset dimensions)
const PUZZLE_TEXTURE_HEIGHT = 1024 # Height of puzzle textures (should match actual asset dimensions)

# Base viewport resolution (from project settings - defaults)
const BASE_RESOLUTION_WIDTH = 1080 # Base viewport width
const BASE_RESOLUTION_HEIGHT = 1920 # Base viewport height

# Actual viewport dimensions (set at runtime during loading)
# These will be initialized to base resolution and updated by loading_screen
var actual_viewport_width: float = BASE_RESOLUTION_WIDTH
var actual_viewport_height: float = BASE_RESOLUTION_HEIGHT
var actual_available_width: float = 0.0 # Available width (viewport - margins if any)
var actual_available_height: float = 0.0 # Available height (viewport - HUD heights)

# HUD specifications (configurable heights)
const TOP_HUD_HEIGHT = 80 # Height of top HUD in pixels
const BOTTOM_HUD_HEIGHT = 180 # Height of bottom HUD in pixels

# Puzzle area margins (per puzzle type)
const TILE_PUZZLE_MARGIN = 30 # Margin for tile puzzle from each side (top/left/right/bottom)
const ARROW_PUZZLE_MARGIN = 30 # Margin for arrow puzzle from each side (top/left/right/bottom)
const ROW_TILE_PUZZLE_MARGIN = 0 # Row tile puzzle uses entire available area

# Enums
enum Difficulty {
	EASY = 0,
	HARD = 1
}

enum PuzzleType {
	TILE_PUZZLE = 0,
	SPIRAL_TWIST = 1,
	ARROW_PUZZLE = 2,
	ROW_TILE_PUZZLE = 3
}

## Helper function: Convert Difficulty enum to string
static func difficulty_to_string(diff: Difficulty) -> String:
	match diff:
		Difficulty.EASY:
			return "easy"
		Difficulty.HARD:
			return "hard"
		_:
			return "easy"

## Helper function: Convert string to Difficulty enum
static func string_to_difficulty(diff_str: String) -> Difficulty:
	match diff_str.to_lower():
		"easy":
			return Difficulty.EASY
		"hard":
			return Difficulty.HARD
		_:
			return Difficulty.EASY

## Initialize actual viewport dimensions from a viewport node
## Should be called once during loading screen
func initialize_viewport_dimensions(viewport_rect_size: Vector2) -> void:
	actual_viewport_width = viewport_rect_size.x
	actual_viewport_height = viewport_rect_size.y

	# Calculate available dimensions (viewport minus HUD areas)
	# Assume standard vbox_separation = 20
	var used_height = TOP_HUD_HEIGHT + BOTTOM_HUD_HEIGHT + (20 * 2)
	actual_available_height = actual_viewport_height - used_height
	actual_available_width = actual_viewport_width

	print("GameConstants: Viewport initialized to %.1fx%.1f" % [actual_viewport_width, actual_viewport_height])
	print("GameConstants: Available area set to %.1fx%.1f" % [actual_available_width, actual_available_height])

## Get actual viewport width (set during loading)
func get_viewport_width() -> float:
	return actual_viewport_width

## Get actual viewport height (set during loading)
func get_viewport_height() -> float:
	return actual_viewport_height

## Get available width for puzzles (viewport width minus any margins)
func get_available_width() -> float:
	return actual_available_width

## Get available height for puzzles (viewport height minus HUD heights)
func get_available_height() -> float:
	return actual_available_height
