extends Control

## Loading Screen
## Loads game data and navigates to appropriate screen

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var loading_label: Label = $LoadingLabel

var loading_progress: float = 0.0
var loading_complete: bool = false

func _ready() -> void:
	# Start loading process
	_start_loading()

func _process(delta: float) -> void:
	if not loading_complete:
		# Simulate loading progress
		loading_progress += delta * 50.0  # Adjust speed as needed
		progress_bar.value = min(loading_progress, 100.0)

		# Check if loading is complete
		if loading_progress >= 100.0:
			loading_complete = true
			_on_loading_complete()

func _start_loading() -> void:
	# Load levels data
	var levels_loaded = LevelManager.load_levels()
	if not levels_loaded:
		push_error("Failed to load levels.json")
		loading_label.text = "Error loading game data!"
		return

	# Load save data (already done in ProgressManager._ready())
	# ProgressManager loads automatically on startup

	print("Loading game data...")

func _on_loading_complete() -> void:
	print("Loading complete!")

	# Navigate based on current level
	# If first time playing (level 1), go directly to gameplay
	# Otherwise, show level selection
	await get_tree().create_timer(0.5).timeout  # Small delay for visual feedback

	if ProgressManager.current_level == 1 and not _has_any_stars():
		# First time player - go directly to Level 1 Easy
		GameManager.navigate_to_gameplay(1, GameConstants.Difficulty.EASY)
	else:
		# Returning player - show level selection
		GameManager.navigate_to_level_selection()

## Check if player has earned any stars (not first time playing)
func _has_any_stars() -> bool:
	for level_id in ProgressManager.stars.keys():
		var level_stars = ProgressManager.stars[level_id]
		if level_stars.get("easy", false) or level_stars.get("normal", false) or level_stars.get("hard", false):
			return true
	return false
