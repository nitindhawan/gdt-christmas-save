extends Node

## Game Manager AutoLoad Singleton
## Handles scene navigation and tracks current game state

# Current game state
var current_level: int = 1
var current_difficulty: int = GameConstants.Difficulty.EASY

# Scene paths
const LOADING_SCREEN = "res://scenes/loading_screen.tscn"
const LEVEL_SELECTION = "res://scenes/level_selection.tscn"
const DIFFICULTY_SELECTION = "res://scenes/difficulty_selection.tscn"
const GAMEPLAY_SCREEN = "res://scenes/gameplay_screen.tscn"
const LEVEL_COMPLETE_SCREEN = "res://scenes/level_complete_screen.tscn"

## Navigate to Loading Screen
func navigate_to_loading() -> void:
	_change_scene(LOADING_SCREEN)

## Navigate to Level Selection
func navigate_to_level_selection() -> void:
	_change_scene(LEVEL_SELECTION)

## Navigate to Difficulty Selection for a specific level
func navigate_to_difficulty_selection(level_id: int) -> void:
	current_level = level_id
	_change_scene(DIFFICULTY_SELECTION)

## Navigate to Gameplay Screen with level and difficulty
func navigate_to_gameplay(level_id: int, difficulty: int) -> void:
	current_level = level_id
	current_difficulty = difficulty
	_change_scene(GAMEPLAY_SCREEN)

## Navigate to Level Complete Screen
func navigate_to_level_complete() -> void:
	_change_scene(LEVEL_COMPLETE_SCREEN)

## Internal function to change scenes
func _change_scene(scene_path: String) -> void:
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("Failed to change scene to: " + scene_path)

## Get current level ID
func get_current_level() -> int:
	return current_level

## Get current difficulty
func get_current_difficulty() -> int:
	return current_difficulty

## Get current difficulty as string
func get_current_difficulty_string() -> String:
	return GameConstants.difficulty_to_string(current_difficulty)
