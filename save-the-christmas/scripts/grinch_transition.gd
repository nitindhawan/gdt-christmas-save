extends Control

## Grinch Transition Animation
## Plays smoke animation when transitioning from difficulty selection to puzzle

signal transition_complete

@onready var animation_player = $AnimationPlayer
@onready var level_background = $LevelBackground

var pending_texture: Texture2D = null

func _ready() -> void:
	print("Grinch transition ready")
	animation_player.animation_finished.connect(_on_animation_finished)

	# Apply pending texture if it was set before _ready()
	if pending_texture != null:
		level_background.texture = pending_texture
		pending_texture = null

func set_level_texture(texture: Texture2D) -> void:
	# If _ready hasn't been called yet, store texture for later
	if not is_node_ready():
		pending_texture = texture
	else:
		level_background.texture = texture

func play_transition() -> void:
	print("Playing grinch_smoke animation")
	animation_player.play("grinch_smoke")

func _on_animation_finished(anim_name: String) -> void:
	print("Animation finished: ", anim_name)
	if anim_name == "grinch_smoke":
		print("Emitting transition_complete signal")
		transition_complete.emit()
		queue_free()
