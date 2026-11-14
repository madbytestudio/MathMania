extends Node
## Autoload `Sfx`
## Pemain audio ringkas untuk kesan bunyi. Bunyi dijana secara sintetik
## (lihat assets/sfx) supaya projek kekal ringan.

const SOUNDS := {
	"click": "res://assets/sfx/click.wav",
	"correct": "res://assets/sfx/correct.wav",
	"wrong": "res://assets/sfx/wrong.wav",
	"win": "res://assets/sfx/win.wav",
	"pop": "res://assets/sfx/pop.wav",
}

var _players: Dictionary = {}
var _muted: bool = false


func _ready() -> void:
	for key in SOUNDS:
		var player := AudioStreamPlayer.new()
		player.stream = load(SOUNDS[key])
		player.volume_db = -7.0
		player.bus = "Master"
		add_child(player)
		_players[key] = player


## Mainkan kesan bunyi mengikut nama kunci dalam SOUNDS.
func play(key: String) -> void:
	if _muted:
		return
	var player: AudioStreamPlayer = _players.get(key)
	if player:
		player.play()


func set_muted(value: bool) -> void:
	_muted = value


func is_muted() -> bool:
	return _muted
