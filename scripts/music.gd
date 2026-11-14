extends Node
## Autoload `Music`
## Muzik latar lembut yang dimainkan berulang. Tetapan hidup/mati disimpan
## oleh GameState supaya kekal antara sesi.

const TRACK := "res://assets/music/theme.wav"

var _player: AudioStreamPlayer
var _enabled: bool = true
## Pelayan audio "headless" tidak memproses campuran, jadi main balik tidak
## pernah dilepaskan dan Godot melaporkan objek tertinggal semasa keluar.
var _silent: bool = false


func _ready() -> void:
	_silent = DisplayServer.get_name() == "headless"

	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	_player.volume_db = -13.0

	var stream: AudioStream = load(TRACK)
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		# 16-bit stereo = 4 bait setiap bingkai.
		wav.loop_end = int(wav.data.size() / 4)
	_player.stream = stream
	add_child(_player)

	var state := get_node_or_null("/root/GameState")
	if state:
		_enabled = bool(state.music_on)
	if _enabled and not _silent:
		_player.play()


## Hidupkan atau matikan muzik latar.
func set_enabled(value: bool) -> void:
	_enabled = value
	if _player == null:
		return
	if value:
		if not _player.playing and not _silent:
			_player.play()
	else:
		_player.stop()


func is_enabled() -> bool:
	return _enabled


## Lepaskan strim semasa keluar supaya tiada objek audio yang tertinggal.
func _exit_tree() -> void:
	if _player == null:
		return
	_player.stop()
	_player.stream = null
