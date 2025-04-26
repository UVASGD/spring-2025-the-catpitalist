extends Node
var frozen = false 
var day_num = 1
var time = (6 * 3600) / TIME_SCALE # 6 am scaled to game time
const DAY_LENGTH = 600 #num of seconds (real life) in a day (game)
#const DAY_LENGTH = 60 #debug day speed (very fast)
const TIME_SCALE = 86400 / DAY_LENGTH

# Time thresholds in game seconds
const DAWN_END_TIME = (6 * 3600) / TIME_SCALE
const DUSK_START_TIME = (18 * 3600) / TIME_SCALE
const MIDNIGHT_TIME = (24 * 3600) / TIME_SCALE
const EXHAUSTED_TIME = (2 * 3600) / TIME_SCALE

# State tracking
var is_dawn = true
var is_dusk = false
var is_day = false
var is_night = false

# Previous frame time tracking for threshold detection
var prev_time = 0

enum{SPRING, SUMMER, FALL, WINTER}
var season = SPRING
var snowing = false
var raining = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prev_time = time
	update_day_state(time)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frozen:
		return

	prev_time = time
	time += delta
	
	print(time)
	
	check_time_thresholds()

func check_time_thresholds():
	if prev_time < DAWN_END_TIME && time >= DAWN_END_TIME:
		on_dawn_end()
	if prev_time < DUSK_START_TIME && time >= DUSK_START_TIME:
		on_dusk_start()
	if prev_time < MIDNIGHT_TIME && time >= MIDNIGHT_TIME:
		on_midnight()
	if prev_time < EXHAUSTED_TIME && time >= EXHAUSTED_TIME:
		sleep()

func update_day_state(current_time):
	if current_time < DAWN_END_TIME:
		is_dawn = true
		is_day = false
		is_dusk = false
		is_night = true
	elif current_time < DUSK_START_TIME:
		is_dawn = false
		is_day = true
		is_dusk = false
		is_night = false
	else:
		is_dawn = false
		is_day = false
		is_dusk = true
		is_night = true

func end_day():
	day_num += 1 
	SignalBus.emit_signal("day_end")
	
	#on_dawn_end()
	
	check_time_thresholds()
	update_day_state(time)
	determine_season()
	reset_weather()
	print("day ended")
	

func determine_season():
	if day_num >= 91 and day_num <= 182:
		season = SUMMER
	elif day_num >= 182 and day_num <= 273:
		season = FALL 
	elif day_num >= 273:
		season = WINTER
	if day_num == 366:
		#end game
		return
		
func freeze():
	frozen = true
	
func unfreeze():
	frozen = false

func get_time_string() -> String:
	var suffix = "am"
	var scaled_time = time * TIME_SCALE
	var hours = int(scaled_time) / 3600
	if hours < 1:
		hours = 12
	elif hours > 11:
		hours = hours % 12
		suffix = "pm"
	return str(hours).pad_zeros(2)+ " " +suffix

func on_dawn_end():
	is_dawn = false
	is_night = false
	is_day = true
	print("dawn: transition to daytime")
	SignalBus.emit_signal("dawn_end")
	generate_weather()

func generate_weather():
	if season != SUMMER:
		if randi_range(0,1) == 1: # 50% chance of rain, change later
			if season == WINTER:
				snowing = true
				SignalBus.emit_signal("snow_start")
			else:
				raining = true
				SignalBus.emit_signal("rain_start")

func reset_weather():
	if raining:
		raining = false
		SignalBus.emit_signal("rain_end")
	if snowing:
		snowing = false
		SignalBus.emit_signal("snow_end")

func on_dusk_start():
	is_day = false
	is_night = true
	is_dusk = true
	SignalBus.emit_signal("dusk_start")
	print("dusk: transition to night time")

func on_midnight():
	time = 0
	is_dawn = true
	is_dusk = false
	end_day()
	
func sleep(exhausted=true):
	freeze()
	if exhausted:
		await PlayerData.player.fall_asleep()
	day_num -= 1
	await sleep_screen()
	SceneSwapper.teleport_home()
	unfreeze()
	if exhausted:
		time = 10 * 3600 / TIME_SCALE #set time to 10am
	else:
		time = 8 * 3600 / TIME_SCALE #set time to 8am
	prev_time = time
	end_day()

func sleep_screen():
	return
