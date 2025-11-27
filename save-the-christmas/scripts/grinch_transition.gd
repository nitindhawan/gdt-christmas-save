extends Control

## Grinch Transition Animation
## Plays smoke animation when transitioning from difficulty selection to puzzle

signal transition_complete

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func play_transition() -> void:
	animation_player.play("grinch_smoke")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "grinch_smoke":
		transition_complete.emit()
		queue_free()
