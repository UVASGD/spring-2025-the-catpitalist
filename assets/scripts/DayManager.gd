extends Node
var frozen = false
var day_num = 1
var time = (6 * 3600) / TIME_SCALE # 6 am scaled to game time
const DAY_LENGTH = 600 #num of seconds (real life) in a day (game)
const TIME_SCALE = 86400 / DAY_LENGTH
var is_dawn = true
var is_dusk = false
var is_day = false
var is_night = false
@onready var dawn_end_timer: Timer
@onready var dusk_start_timer: Timer
@onready var midnight_timer: Timer
enum{SPRING, SUMMER, FALL, WINTER}
var season = SPRING
var snowing = false
var raining = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_timers()
	pass # Replace with function body.

func set_timers():
	var offset = 0
	if day_num == 1: # we start at 6 am on the first day, so all the timers should account for that
		offset = 5.9
	dawn_end_timer = Timer.new()
	dawn_end_timer.wait_time = ((6-offset) * 3600) / TIME_SCALE
	dawn_end_timer.connect("timeout", _on_dawn_end)
	dawn_end_timer.one_shot = true
	add_child(dawn_end_timer)
	dawn_end_timer.start()
	
	dusk_start_timer = Timer.new()
	dusk_start_timer.wait_time = ((18-offset) * 3600) / TIME_SCALE
	dusk_start_timer.connect("timeout", _on_dusk_start)
	dusk_start_timer.one_shot = true
	add_child(dusk_start_timer)
	dusk_start_timer.start()
	
	midnight_timer = Timer.new()
	midnight_timer.wait_time = ((24-offset) * 3600) / TIME_SCALE
	midnight_timer.connect("timeout", _on_midnight)
	midnight_timer.one_shot = true
	add_child(midnight_timer)
	midnight_timer.start()
	
func reset_timers():
	dawn_end_timer.wait_time = (6 * 3600) / TIME_SCALE
	dawn_end_timer.start()
	dusk_start_timer.wait_time = (18 * 3600) / TIME_SCALE
	dusk_start_timer.start()
	midnight_timer.wait_time = (24 * 3600) / TIME_SCALE
	midnight_timer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frozen:
		return

	time += delta
	pass

func end_day():
	time = 0
	day_num += 1 
	SignalBus.emit_signal("day_end")
	determine_season()
	#reset dawn and dusk timers
	reset_timers()
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

func _on_dawn_end():
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

func _on_dusk_start():
	is_day = false
	is_night = true
	is_dusk = true
	SignalBus.emit_signal("dusk_start")
	print("dusk: transition to night time")

func _on_midnight():
	is_dawn = true
	is_dusk = false
	end_day()
