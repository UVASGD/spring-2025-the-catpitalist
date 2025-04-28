extends Control

@onready var textbox: Label = $cardboard/textbox
@onready var portrait: TextureRect = $cardboard/portrait

@onready var speakerlabel: Label = $speakerlabel
@onready var choices: VBoxContainer = $choices
@export var TEXT_SPEED:int = 3

var conversation:Conversation = null
var is_skipping = false

var awaiting_choice
var dialogue_choice

func _ready() -> void:
	SignalBus.connect("new_dialogue", _on_dialogue)

	self.hide()

func format_speakername(npc_name:String):
	if npc_name.ends_with("*") or npc_name.ends_with("^"): #strip * or ^ from end of NPCs that are duplicates
		return npc_name.substr(0,len(npc_name)-1)
	else:
		return npc_name

func _input(event: InputEvent) -> void:
	if event.is_action_released("skipdialogue"):
		await skip()

func write(message: Message) -> void:
	var text: String = message.text
	var speaker: String = format_speakername(message.speaker)
	speakerlabel.text = speaker
	textbox.text = ""
	
	var index = 0
	is_skipping = false
	
	while index < text.length():
		if is_skipping and index < text.length() - 10: # prevent accidental double skips if text is almost done showing
			textbox.text = text
			break
		textbox.text += text[index]
		if index>1 and text[index-1] == " ":
			Dialogue.play_voice(text[index],speaker)
		index += 1
		await get_tree().create_timer(0.05 / TEXT_SPEED).timeout # Adjust the delay as needed
	return

func skip() -> void:
	is_skipping = true
	await get_tree().create_timer(0.5).timeout

func _on_dialogue(convo: Conversation) -> void:
	DayManager.freeze()
	conversation = convo
	var npc = convo.get_npc()
	var nportrait = npc.get_portrait()
	portrait.texture = nportrait
	self.show()
	await show_conversation()
	self.hide()
	SignalBus.emit_signal("dialogue_finished")
	if convo.opens_shop:
		convo.get_npc().open_shop()
	else:
		DayManager.unfreeze()

func show_conversation() -> void:
	if conversation:
		var run_message
		for message:Message in conversation.get_messages():
			run_message = true
			var cond = message.item_condition
			var cond_item
			if cond != -1:
				cond_item = Items.get_item(cond)
				cond_item.count = message.item_amount
				var cond_action = message.condition_action
				var num_conditioned_item = PlayerData.player.get_total_item_count(cond_item)
				if cond_action == 1 && num_conditioned_item >= cond_item.count:
					run_message = false
				elif cond_action == 2 && num_conditioned_item < cond_item.count:
					run_message = false
			if run_message:
				await  write(message)
				if message.is_request:
					choices.visible = true
					awaiting_choice = true
					await wait_for_choice()
					await get_tree().create_timer(0.1).timeout
					if dialogue_choice == "yes":
						if PlayerData.player.remove_from_inv(cond_item):
						
							SignalBus.emit_signal("item_given_to_npc", cond_item, conversation.get_npc())
							dialogue_choice = ""
							choices.visible = false
							break
					else:
						conversation.get_npc().current_convo_index -= 1
						NPCS.update_cache(conversation.get_npc())
				else:
					await wait_for_user_input()
					if message.item_condition != -1:
						conversation.get_npc().current_convo_index -= 1
						NPCS.update_cache(conversation.get_npc())
				dialogue_choice = ""
				choices.visible = false
	return

func wait_for_user_input() -> void:
	while not Input.is_action_just_released("skipdialogue"):
		await get_tree().process_frame

func wait_for_choice() -> void:
	while awaiting_choice:
		await get_tree().process_frame
	return

func _on_yes_pressed() -> void:
	print("??")
	awaiting_choice = false
	dialogue_choice = "yes"
	
func _on_no_pressed() -> void:
	print("?")
	awaiting_choice = false
	dialogue_choice = "no"
