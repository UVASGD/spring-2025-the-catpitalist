extends Node

@onready var songplayers = {
	"water main":"res://assets/audio/music/aguaaaaa.mp3",
	"pensive paw": "res://assets/audio/music/among_drip.wav",
	"chasing dragons": "res://assets/audio/music/catnipdealer.wav",
	"cats in the snow": "res://assets/audio/music/cats_in_da_snow.wav",
	"city theme": "res://assets/audio/music/City Day Theme.mp3",
	"weird": "res://assets/audio/music/magicforest_soudns_terirble.wav",
	"water 2": "res://assets/audio/music/Project_5.mp3",
	"rain city": "res://assets/audio/music/raincity2.mp3",
	"garebear shop": "res://assets/audio/music/shop jingle.mp3",
	"o e e a e": "res://assets/audio/music/sky theme.mp3",
	"spacey": "res://assets/audio/music/spacey.mp3",
	"pretty paws": "res://assets/audio/music/pp_ogg.ogg",
	"sleepy kitty": "res://assets/audio/music/sleepykitty.mp3",
	"main": "res://assets/audio/music/main theme cat.mp3",
	"gerardo": "res://assets/audio/music/Schrodinger.mp3",
	"mustard": "res://assets/audio/music/katrick_lameow.mp3",
} # dict with keys = song name (string), and values = AudioStreamPlayer2D
@onready var songplayers_snow = {}
@onready var songplayers_rain = {}

var playlist_stack = []

var path_to_music_dir = "res://assets/audio/music/"
var current_playing = null
var fade_duration = 2
var playlisting_random = false
enum{INFINITE, LOOPING}
var mode = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_music()
	SignalBus.connect("play_random_song", play_random)
	pass # Replace with function body.

func load_music():
	for song_name in songplayers.keys():
		var stream = load(songplayers[song_name]) as AudioStream
		var player = AudioStreamPlayer.new()
		player.stream = stream
		player.bus = "music"
		songplayers[song_name] = player
		add_child(player)

		
func push(playlist: Array[String]):
	if playlist.size() > 0:
		playlist_stack.push_front(playlist)
		play_random()
	#play_random_from_playlist(playlist_stack[0])
	
func pop():
	playlist_stack.pop_front()
	play_random()
	#play_random_from_playlist(playlist_stack[0])

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
	if mode == INFINITE:
		current_playing = null
		play_random()
	if mode == LOOPING:
		play(current_playing)

func play_random():
	if playlist_stack.size() > 0:
		if playlist_stack[0].size() > 0:
			play(playlist_stack[0][randi_range(0, playlist_stack[0].size() - 1)])
	
	"""var keys = songplayers.keys()
	if keys.size() > 0:
		var random_songname = keys[randi() % keys.size()]
		play(random_songname)
	return"""

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
	var keys = songplayers_rain.keys()
	if keys.size() > 0:
		var random_songname = keys[randi() % keys.size()]
		play(random_songname)

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
