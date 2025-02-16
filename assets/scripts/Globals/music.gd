extends Node

@onready var songplayers = {} # dict with keys = song name (string), and values = AudioStreamPlayer2D
@onready var songplayers_snow = {}
@onready var songplayers_rain = {}

var path_to_music_dir = "res://assets/audio/music/"
var current_playing = null
var fade_duration = 5
var playlisting_random = false
enum{INFINITE}
var mode = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_music()
	SignalBus.connect("play_random_song", play_random)
	SignalBus.connect("snow_start", _on_snow_start)
	SignalBus.connect("snow_end", _on_snow_end)
	SignalBus.connect("rain_start", _on_rain_start)
	SignalBus.connect("rain_end", _on_rain_end)
	pass # Replace with function body.

func load_music():
	var dir = DirAccess.open(path_to_music_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".mp3") or file_name.ends_with(".wav"):
				var file_path = path_to_music_dir + file_name
				var stream = load(file_path) as AudioStream
				if stream:
					var player = AudioStreamPlayer.new()
					player.stream = stream
					player.bus = "music"
					var song_name = file_name.get_basename()
					if song_name.contains("rain"):
						songplayers_rain[song_name] = player
					if song_name.contains("snow"):
						songplayers_snow[song_name] = player
					songplayers[song_name] = player
					add_child(player) # Add the player to the scene tree
			file_name = dir.get_next()
		dir.list_dir_end()

func play(songname: String):
	await fade_out()
	var song = songplayers.get(songname)
	if song:
		current_playing = song
		song.play()
		song.connect("finished",_on_song_finish)

func set_mode(newmode):
	mode = newmode

func _on_song_finish():
	current_playing = null
	if mode == INFINITE:
		play_random()

func play_random():
	var keys = songplayers.keys()
	if keys.size() > 0:
		var random_songname = keys[randi() % keys.size()]
		play(random_songname)
	return

func fade_out():
	if current_playing:
		var tween = get_tree().create_tween()
		tween.tween_property(current_playing, "volume_db", current_playing.volume_db-80, fade_duration)
		await tween.finished
		current_playing.stop()
		current_playing.volume_db = 0 # Reset volume for next play
		current_playing = null
	return	

func play_random_snow():
	var keys = songplayers_snow.keys()
	if keys.size() > 0:
		var random_songname = keys[randi() % keys.size()]
		play(random_songname)

func play_random_rain():
	#var keys = songplayers_rain.keys()
	#if keys.size() > 0:
		#var random_songname = keys[randi() % keys.size()]
		#play(random_songname)
	play("rainy_paws")

func _on_snow_start():
	play_random_snow()
	return

func _on_snow_end():
	play_random()
	return

func _on_rain_start():
	play_random_rain()
	return

func _on_rain_end():
	play_random()
	return
