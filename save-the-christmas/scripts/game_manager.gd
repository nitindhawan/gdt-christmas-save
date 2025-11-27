extends Node

## Game Manager AutoLoad Singleton
## Handles scene navigation and tracks current game state

# Current game state
var current_level: int = 1
var current_difficulty: int = GameConstants.Difficulty.EASY

# Scene paths
const LOADING_SCREEN = "res://scenes/loading_screen.tscn"
const GAMEPLAY_SCREEN = "res://scenes/gameplay_screen.tscn"
const LEVEL_COMPLETE_SCREEN = "res://scenes/level_complete_screen.tscn"

# Deprecated scene paths (for reference only)
# const LEVEL_SELECTION = "res://scenes/level_selection.tscn"
# const DIFFICULTY_SELECTION = "res://scenes/difficulty_selection.tscn"

## Navigate to Loading Screen
func navigate_to_loading() -> void:
	_change_scene(LOADING_SCREEN)

## Navigate to Gameplay Screen (new flow - difficulty chosen in popup)
func navigate_to_gameplay_new_flow(level_id: int) -> void:
	current_level = level_id
	current_difficulty = GameConstants.Difficulty.EASY  # Will be chosen in popup
	_change_scene(GAMEPLAY_SCREEN)

## Navigate to Level Complete Screen
func navigate_to_level_complete() -> void:
	_change_scene(LEVEL_COMPLETE_SCREEN)

# DEPRECATED METHODS (no longer used in new UX flow)
# func navigate_to_level_selection() -> void:
#     # DEPRECATED - Level selection removed in new flow
#     pass
#
# func navigate_to_difficulty_selection(level_id: int) -> void:
#     # DEPRECATED - Difficulty selection now done via popup
#     pass
#
# func navigate_to_gameplay(level_id: int, difficulty: int) -> void:
#     # DEPRECATED - Use navigate_to_gameplay_new_flow() instead
#     pass

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
