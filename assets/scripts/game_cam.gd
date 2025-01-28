extends Camera2D
@onready var day: Label = $Control/VBoxContainer/HBoxContainer/day
@onready var time: Label = $Control/VBoxContainer/HBoxContainer/time
@onready var money: Label = $Control/VBoxContainer/HBoxContainer2/money
@onready var season_label: Label = $Control/VBoxContainer/HBoxContainer2/Season

@onready var rain: ColorRect = $rain
@onready var snow: ColorRect = $snow


var inv = null
var signaled = false
var inv_cooldown = false
var inv_showing = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("rain_start", _on_rain)
	SignalBus.connect("snow_start", _on_snow)
	SignalBus.connect("snow_end", _on_snow_end)
	SignalBus.connect("rain_end", _on_rain_end)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not signaled:
		signaled = true
		SignalBus.emit_signal("cam_ready", self)
	
	set_day_label()
	set_time_label()
	set_money_label()
	set_season_label()
	pass

func set_day_label():
	day.text = "Day: " + str(DayManager.day_num)

func set_time_label():
	time.text = "Time: " + DayManager.get_time_string()

func set_money_label():
	var currentMoney = PlayerData.get_current_money()
	if currentMoney != null:
		if currentMoney < 1:
			money.text = "Money: broke AF LMAO"
		else:
			money.text = "Money: " + str(currentMoney)

func set_season_label():
	var season = DayManager.season
	var seasons = ["Spring", "Summer", "Fall", "Winter"]
	season_label.text = "Season: " + seasons[season]
	
func open_inv():
	if inv_cooldown:
		return
	if inv_showing:
		close_inv()
		return
	SignalBus.emit_signal("inv_opened")
	inv_showing = true
	inv = load("res://assets/scenes/inventory_screen.tscn").instantiate()
	add_child(inv)
	$Hotbar.hide()
	
func close_inv():
	SignalBus.emit_signal("inv_closed")
	remove_child(inv)
	inv.queue_free()
	inv_cooldown = true
	inv_showing = false
	$Hotbar.show()
	await get_tree().create_timer(0.5).timeout
	inv_cooldown = false

func _on_rain():
	var fadetween = get_tree().create_tween()
	fadetween.tween_property(rain, "modulate", Color(50,50,255,255), 3)

func _on_rain_end():
	var fadetween = get_tree().create_tween()
	fadetween.tween_property(rain, "modulate", Color(50,50,255,0), 3)

func _on_snow():
	var fadetween = get_tree().create_tween()
	fadetween.tween_property(snow, "modulate", Color(50,50,255,255), 3)

func _on_snow_end():
	var fadetween = get_tree().create_tween()
	fadetween.tween_property(snow, "modulate", Color(50,50,255,0), 3)
