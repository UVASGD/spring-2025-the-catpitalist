extends Control
var disabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	pass # Replace with function body.

func enable():
	self.show()
	disabled = false

func disable():
	self.hide()
	disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_skipday_pressed() -> void:
	if disabled:
		return
	SignalBus.emit_signal("midnight_debug")
	DayManager.end_day()
	pass # Replace with function body.


func _on_skipweek_pressed() -> void:
	if disabled:
		return
	for i in range(0,7):
		DayManager.end_day()
	pass # Replace with function body.


func _on_tree_exited() -> void:
	if disabled:
		return
	disabled = true
	pass # Replace with function body.


func _on_set_money_input_text_submitted(new_text: String) -> void:
	if(new_text.is_valid_int()):
		PlayerData.player.money = int(new_text)
	pass # Replace with function body.


func _on_add_money_input_text_submitted(new_text: String) -> void:
	if(new_text.is_valid_int()):
		PlayerData.player.money += int(new_text)
	pass # Replace with function body.


func _on_give_blurbo_water_pressed() -> void:
	SignalBus.emit_signal("item_given_to_npc", Items.get_item(1), DebugManager.Blurbo)
	PlayerData.remove_inv(3)
	pass # Replace with function body.


func _on_send_convo_signal_pressed() -> void:
	SignalBus.emit_signal("convotest")
	pass # Replace with function body.
