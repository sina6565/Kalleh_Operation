extends Node

# AudioManager stub - organizes audio playback and exposes named sounds
# Replace the exported AudioStream resources with final assets later

@export var sfx_jump: AudioStream
@export var sfx_hit: AudioStream
@export var sfx_collect: AudioStream
@export var music: AudioStream

onready var _player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(_player)
	_player.autoplay = false

func play_sfx(stream: AudioStream) -> void:
	if not stream: return
	_player.stream = stream
	_player.play()

func play_music() -> void:
	if not music: return
	if _player.playing:
		_player.stop()
	_player.stream = music
	_player.play()
