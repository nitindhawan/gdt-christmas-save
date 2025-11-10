# Godot 4 Naming Conventions

Godot 4 employs specific naming conventions to enhance code readability and maintainability. While consistency is key, here are the generally recommended conventions:

## File and Folder Names
*(including scene files and scripts)*

- **Convention**: Use `snake_case` (lowercase with underscores between words)
- **Examples**: 
  - `player_character.tscn`
  - `enemy_ai.gd`
  - `assets/textures/player_sprites/`

## Scene Names vs Scene File Names
*(Important distinction for scenes)*

- **Scene File Names**: Use `snake_case` (following file naming convention)
  - Examples: `main_menu.tscn`, `game_scene.tscn`, `settings_screen.tscn`
- **Scene Root Node Names**: Use `PascalCase` (following node naming convention)
  - Examples: `MainMenu`, `GameScene`, `SettingsScreen`
- **Note**: Scenes are types of nodes in Godot 4, so the root node follows PascalCase while the file follows snake_case

## Class Names
*(defined with class_name)*

- **Convention**: Use `PascalCase` (first letter of each word capitalized, no spaces)
- **Examples**: 
  - `PlayerController`
  - `EnemyAI`

## Node Names
*(in the scene tree)*

- **Convention**: Use `PascalCase`
- **Examples**: 
  - `CharacterBody3D`
  - `Sprite2D`
  - `AnimationPlayer`

## Variables and Functions

- **Convention**: Use `snake_case`
- **Examples**: 
  - `player_speed`
  - `get_player_health()`

## Constants

- **Convention**: Use `CONSTANT_CASE` (all uppercase with underscores between words)
- **Examples**: 
  - `MAX_SPEED`
  - `GRAVITY_STRENGTH`

## Signals

- **Convention**: Use `snake_case`, often with a past tense verb or action
- **Examples**: 
  - `door_opened`
  - `player_died`

## Enums

- **Enum names**: Use `PascalCase`
- **Enum members**: Use `CONSTANT_CASE`
- **Example**:
```gdscript
enum Planets {EARTH, MARS}
```

## Key Principles

- **Descriptive Naming**: Names should clearly indicate the purpose of the variable, function, or entity
- **Consistency**: Maintain the chosen conventions throughout your project
- **Case Sensitivity Awareness**: When dealing with file systems, using lowercase for folders and files helps prevent issues on case-insensitive platforms