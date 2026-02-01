extends CanvasLayer

signal save_selected(slot: int)
signal closed

@onready var slot_container: VBoxContainer = $Panel/VBox/SlotContainer
@onready var title_label: Label = $Panel/VBox/Title
@onready var back_btn: Button = $Panel/VBox/BackBtn

var mode = "load" # "load", "save", or "new_game"
var slot_buttons = []
var delete_buttons = []
var is_refreshing = false

func _ready() -> void:
	pass

func set_mode(new_mode: String):
	mode = new_mode
	match mode:
		"load":
			title_label.text = "Load Game"
		"save":
			title_label.text = "Save Game"
		"new_game":
			title_label.text = "New Game - Select Slot"
	refresh_slots()

func refresh_slots():
	if is_refreshing:
		return
	is_refreshing = true
	
	for child in slot_container.get_children():
		child.queue_free()
	slot_buttons.clear()
	delete_buttons.clear()
	
	await get_tree().process_frame
	
	var saves = SaveManager.get_all_saves()
	for save_info in saves:
		var slot = save_info["slot"]
		var data = save_info["data"]
		
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var slot_btn = Button.new()
		slot_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_btn.custom_minimum_size = Vector2(400, 60)
		
		if data == null or data.is_empty():
			slot_btn.text = "Slot " + str(slot + 1) + " - Empty"
			if mode == "load":
				slot_btn.disabled = true
		else:
			var season = SaveManager.get_season_name(data.get("season", 0))
			var day = data.get("day", 1)
			var money = data.get("money", 0)
			var timestamp = data.get("timestamp", "")
			slot_btn.text = "Slot " + str(slot + 1) + " | Day " + str(day) + " | " + season + " | $" + str(money)
			if timestamp != "":
				slot_btn.text += "\n" + timestamp
		
		slot_btn.pressed.connect(_on_slot_pressed.bind(slot))
		slot_buttons.append(slot_btn)
		hbox.add_child(slot_btn)
		
		# Add delete button if save exists
		if data != null and not data.is_empty():
			var del_btn = Button.new()
			del_btn.text = "X"
			del_btn.custom_minimum_size = Vector2(40, 60)
			del_btn.pressed.connect(_on_delete_pressed.bind(slot))
			del_btn.modulate = Color(1, 0.4, 0.4)
			delete_buttons.append(del_btn)
			hbox.add_child(del_btn)
		
		slot_container.add_child(hbox)
	
	is_refreshing = false

func _on_slot_pressed(slot: int):
	match mode:
		"load":
			if SaveManager.load_game(slot):
				emit_signal("save_selected", slot)
				queue_free()
				# Let SaveManager handle the scene loading
				SaveManager.load_saved_scene()
		"save":
			SaveManager.save_game(slot)
			refresh_slots()
		"new_game":
			SaveManager.current_slot = slot
			emit_signal("save_selected", slot)
			close()

func _on_delete_pressed(slot: int):
	# Show confirmation (simple approach - just delete)
	SaveManager.delete_save(slot)
	refresh_slots()

func _on_back_btn_pressed() -> void:
	close()

func close():
	emit_signal("closed")
	queue_free()
