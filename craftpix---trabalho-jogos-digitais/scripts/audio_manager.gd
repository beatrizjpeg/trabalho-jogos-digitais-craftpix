extends Node

var sfx_streams = {
	"jump": preload("res://assets/audio/Jump28.wav"),
	"gem": preload("res://assets/audio/Pickup37.wav"),
	"hit": preload("res://assets/audio/Hit33.wav"),
	"click": preload("res://assets/audio/Blip10.wav"),
	"powerup": preload("res://assets/audio/PowerUp3.wav"),
	"checkpoint": preload("res://assets/audio/Pickup29.wav")
}

# Ajuste o volume base de cada som aqui
var sfx_volumes = {
	"jump": -18.0,
	"gem": -15.0,
	"hit": -4.0,
	"click": -6.0,
	"powerup": -6.0,
	"checkpoint": -6.0
}

var music_streams = {
	"menu": preload("res://assets/audio/music_menu.mp3"),
	"level1": preload("res://assets/audio/music_level1.mp3"),
	"level3": preload("res://assets/audio/music_level3.mp3"),
	"level5": preload("res://assets/audio/music_level5.mp3")
}

var music_player: AudioStreamPlayer
var current_music: String = ""
var base_music_db: float = -12.0

# Controles das Opções
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var is_music_paused: bool = false
var is_muted_all: bool = false


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	_apply_music_volume()


func play_sfx(sound_name: String, pitch: float = 1.0) -> void:
	if is_muted_all or sfx_volume <= 0.001:
		return
	if not sfx_streams.has(sound_name):
		return

	var player = AudioStreamPlayer.new()
	player.stream = sfx_streams[sound_name]
	var base_db = sfx_volumes.get(sound_name, 0.0)
	player.volume_db = base_db + linear_to_db(sfx_volume)

	# Variação leve automática para não cansar o ouvido
	if pitch == 1.0 and (sound_name == "jump" or sound_name == "gem"):
		player.pitch_scale = randf_range(0.92, 1.08)
	else:
		player.pitch_scale = pitch

	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func play_music(music_name: String, volume_db: float = -12.0) -> void:
	if not music_streams.has(music_name):
		return
	if current_music == music_name and (music_player.playing or is_music_paused):
		return

	current_music = music_name
	base_music_db = volume_db
	var stream = music_streams[music_name]
	if stream is AudioStreamMP3:
		stream.loop = true

	music_player.stream = stream
	_apply_music_volume()
	music_player.play()
	music_player.stream_paused = is_music_paused


func stop_music() -> void:
	music_player.stop()
	current_music = ""


func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	_apply_music_volume()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)


func set_music_paused(paused: bool) -> void:
	is_music_paused = paused
	if music_player:
		music_player.stream_paused = paused


func set_muted_all(muted: bool) -> void:
	is_muted_all = muted
	_apply_music_volume()


func _apply_music_volume() -> void:
	if not music_player:
		return
	if is_muted_all or music_volume <= 0.001:
		music_player.volume_db = -80.0
	else:
		music_player.volume_db = base_music_db + linear_to_db(music_volume)
