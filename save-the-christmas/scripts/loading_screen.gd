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

	# Small delay for visual feedback
	await get_tree().create_timer(0.5).timeout

	# Always navigate to gameplay with current level
	var current_level = ProgressManager.current_level
	GameManager.navigate_to_gameplay_new_flow(current_level)
