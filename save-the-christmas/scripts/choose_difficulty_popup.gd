extends Control

## Choose Difficulty Popup
## Modal popup that allows player to select Easy or Hard difficulty

signal difficulty_chosen(difficulty: int)

@onready var easy_button = $CenterContainer/PanelContainer/VBoxContainer/ButtonContainer/EasyButton
@onready var hard_button = $CenterContainer/PanelContainer/VBoxContainer/ButtonContainer/HardButton

func _ready() -> void:
	_setup_buttons()

func _setup_buttons() -> void:
	ThemeManager.apply_button_theme(easy_button, ThemeManager.COLOR_PRIMARY_GREEN, "Play Easy")
	ThemeManager.apply_button_theme(hard_button, ThemeManager.COLOR_PRIMARY_RED, "Play Hard")

func _on_easy_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")
	difficulty_chosen.emit(GameConstants.Difficulty.EASY)
	queue_free()

func _on_hard_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("button_click")
	difficulty_chosen.emit(GameConstants.Difficulty.HARD)
	queue_free()
