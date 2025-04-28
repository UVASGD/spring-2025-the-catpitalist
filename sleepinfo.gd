extends CanvasLayer
@onready var label_2: Label = $TextureRect/VBoxContainer/Label2
@onready var label: Label = $TextureRect/VBoxContainer/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_2.text = "Total Money Made: " + str(PlayerData.get_money_conversion(PlayerData.player.total_money_made))
	label.text = "Day " + str(DayManager.day_num-1)+ " Over!"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	SignalBus.emit_signal("sleepinfo_done")
	pass # Replace with function body.
