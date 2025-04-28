extends CanvasLayer
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
		PlayerData.player.total_money_made += int(new_text)
		PlayerData.player.check_money()
	pass # Replace with function body.


func _on_add_money_input_text_submitted(new_text: String) -> void:
	if(new_text.is_valid_int()):
		PlayerData.player.money += int(new_text)
		PlayerData.total_money_made += int(new_text)
		PlayerData.player.check_money()
	pass # Replace with function body.


func _on_give_blurbo_water_pressed() -> void:
	SignalBus.emit_signal("unlock_city")
	History.mark("unlock_city")
	SignalBus.emit_signal("unlock_farmhouse")
	History.mark("unlock_farmhouse")
	pass # Replace with function body.


func _on_send_convo_signal_pressed() -> void:
	SignalBus.emit_signal("start_loanshark_quest")
	History.mark("start_loanshark_quest")
	pass # Replace with function body.


func _on_send_convo_signal_2_pressed() -> void:
	SignalBus.emit_signal("made_1000")
	History.mark("made_1000")
	SignalBus.emit_signal("scrappy_shop_closed")
	History.mark("scrappy_shop_closed")
	PlayerData.player.total_money_made = 1000
	PlayerData.player.check_money()
	pass # Replace with function body.


func _on_unlock_underwater_pressed() -> void:
	SignalBus.emit_signal("unlock_water")
	History.mark("unlock_water")
	pass # Replace with function body.


func _on_mention_jelline_pressed() -> void:
	SignalBus.emit_signal("jellina_mentioned")
	History.mark("jellina_mentioned")
	pass # Replace with function body.



func _on_midnight_pressed() -> void:
	DayManager.time = DayManager.MIDNIGHT_TIME -1
	pass # Replace with function body.


func _on_get_poetry_pressed() -> void:
	PlayerData.player.inventory[10] = Items.get_item(29)
	pass # Replace with function body.


func _on_get_strange_piece_pressed() -> void:
	PlayerData.player.add_to_inv(Items.get_item(24))
	pass # Replace with function body.


func _on_get_translator_pressed() -> void:
	PlayerData.player.add_to_inv(Items.get_item(22))
	pass # Replace with function body.


func _on_double_speed_pressed() -> void:
	PlayerData.player.speed *= 2
	pass # Replace with function body.


func _on_half_speed_pressed() -> void:
	PlayerData.player.speed /= 2
	pass # Replace with function body.


func _on_bean_pressed() -> void:
	PlayerData.player.add_to_inv(Items.get_item(25))
	pass # Replace with function body.


func _on_give_starfruit_pressed() -> void:
	PlayerData.player.add_to_inv(Items.get_item(17))
	pass # Replace with function body.


func _on_test_exhaust_pressed() -> void:
	PlayerData.player.fall_asleep()
	pass # Replace with function body.
