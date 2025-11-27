extends Control

## Grinch Transition Animation
## Plays smoke animation when transitioning from difficulty selection to puzzle

signal transition_complete

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	print("Grinch transition ready")
	animation_player.animation_finished.connect(_on_animation_finished)

func play_transition() -> void:
	print("Playing grinch_smoke animation")
	animation_player.play("grinch_smoke")

func _on_animation_finished(anim_name: String) -> void:
	print("Animation finished: ", anim_name)
	if anim_name == "grinch_smoke":
		print("Emitting transition_complete signal")
		transition_complete.emit()
		queue_free()
