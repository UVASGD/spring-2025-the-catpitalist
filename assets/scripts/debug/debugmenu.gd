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
	SignalBus.emit_signal("item_given_to_npc", Items.get_item(1), DebugManager.Blurbo)
	PlayerData.remove_inv(3)
	pass # Replace with function body.


func _on_send_convo_signal_pressed() -> void:
	SignalBus.emit_signal("start_loanshark_quest")
	History.mark("start_loanshark_quest")
	pass # Replace with function body.


func _on_send_convo_signal_2_pressed() -> void:
	SignalBus.emit_signal("made_1000")
	History.mark("made_1000")
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
