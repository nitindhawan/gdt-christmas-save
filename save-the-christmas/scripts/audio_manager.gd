extends Node

## Audio Manager AutoLoad Singleton
## Handles background music, sound effects, and audio settings

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Audio file paths
const MUSIC_PATH = "res://assets/audio/christmas_music_01.ogg"
const SFX_PATHS = {
	"tile_select": "res://assets/audio/tile_select.ogg",
	"tile_swap": "res://assets/audio/tile_swap.ogg",
	"level_complete": "res://assets/audio/level_complete.ogg",
	"button_click": "res://assets/audio/button_click.ogg",
	"hint_used": "res://assets/audio/hint_used.ogg"
}

# Cached sound effects
var sfx_cache: Dictionary = {}

func _ready() -> void:
	_setup_audio_players()
	_load_audio_settings()

## Setup audio players
func _setup_audio_players() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Master"
	add_child(music_player)

	# Create SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "Master"
	add_child(sfx_player)

	print("Audio players initialized")

## Load audio settings from ProgressManager
func _load_audio_settings() -> void:
	if ProgressManager:
		set_music_enabled(ProgressManager.music_enabled)
		set_sound_enabled(ProgressManager.sound_enabled)
		set_music_volume(ProgressManager.music_volume)
		set_sound_volume(ProgressManager.sound_volume)

## Play background music
func play_music(loop: bool = true) -> void:
	if not ProgressManager.music_enabled:
		return

	if music_player.playing:
		return  # Already playing

	if ResourceLoader.exists(MUSIC_PATH):
		var stream = load(MUSIC_PATH) as AudioStream
		if stream != null:
			music_player.stream = stream
			music_player.volume_db = linear_to_db(ProgressManager.music_volume)
			if loop and stream is AudioStreamOggVorbis:
				stream.loop = true
			music_player.play()
			print("Started playing background music")
		else:
			push_warning("Failed to load music file: " + MUSIC_PATH)
	else:
		push_warning("Music file not found: " + MUSIC_PATH)

## Stop background music
func stop_music() -> void:
	if music_player.playing:
		music_player.stop()
		print("Stopped background music")

## Play a sound effect by name
func play_sfx(sfx_name: String) -> void:
	if not ProgressManager.sound_enabled:
		return

	if not SFX_PATHS.has(sfx_name):
		push_warning("Unknown SFX name: " + sfx_name)
		return

	var sfx_path = SFX_PATHS[sfx_name]

	# Try to load from cache first
	var stream: AudioStream = null
	if sfx_cache.has(sfx_name):
		stream = sfx_cache[sfx_name]
	elif ResourceLoader.exists(sfx_path):
		stream = load(sfx_path) as AudioStream
		if stream != null:
			sfx_cache[sfx_name] = stream
		else:
			push_warning("Failed to load SFX file: " + sfx_path)
			return
	else:
		push_warning("SFX file not found: " + sfx_path)
		return

	# Play the sound effect
	sfx_player.stream = stream
	sfx_player.volume_db = linear_to_db(ProgressManager.sound_volume)
	sfx_player.play()

## Set music enabled/disabled
func set_music_enabled(enabled: bool) -> void:
	ProgressManager.music_enabled = enabled
	if enabled:
		play_music()
	else:
		stop_music()

## Set sound enabled/disabled
func set_sound_enabled(enabled: bool) -> void:
	ProgressManager.sound_enabled = enabled

## Set music volume (0.0 to 1.0)
func set_music_volume(volume: float) -> void:
	ProgressManager.music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(ProgressManager.music_volume)

## Set sound volume (0.0 to 1.0)
func set_sound_volume(volume: float) -> void:
	ProgressManager.sound_volume = clamp(volume, 0.0, 1.0)
	sfx_player.volume_db = linear_to_db(ProgressManager.sound_volume)

## Convert linear volume (0-1) to decibels
func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0  # Effectively muted
	return 20.0 * log(linear) / log(10.0)

## Trigger haptic feedback (vibration)
func trigger_haptic(strength: float = 0.5) -> void:
	if not ProgressManager.vibrations_enabled:
		return

	# Vibration API is platform-specific
	# For mobile: Input.vibrate_handheld(duration_ms)
	if OS.has_feature("mobile"):
		var duration_ms = int(strength * 100)  # 0-100ms
		Input.vibrate_handheld(duration_ms)
