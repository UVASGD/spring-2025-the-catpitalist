extends Node2D

@onready var textbox: Label = $textbox
@onready var speakerlabel: Label = $speakerlabel
@export var TEXT_SPEED:int = 1

var conversation = null
var is_skipping = false

func _ready() -> void:
	SignalBus.connect("new_dialogue", _on_dialogue)

	self.hide()



func _input(event: InputEvent) -> void:
	if event.is_action_released("skipdialogue"):
		await skip()

func write(message: Message) -> void:
	var text: String = message.text
	var speaker: String = message.speaker
	speakerlabel.text = speaker
	textbox.text = ""
	
	var index = 0
	is_skipping = false
	
	while index < text.length():
		if is_skipping and index < text.length() - 10: # prevent accidental double skips if text is almost done showing
			textbox.text = text
			break
		textbox.text += text[index]
		Dialogue.play_voice(text[index],speaker)
		index += 1
		await get_tree().create_timer(0.05 / TEXT_SPEED).timeout # Adjust the delay as needed
	return

func skip() -> void:
	is_skipping = true
	await get_tree().create_timer(0.5).timeout

func _on_dialogue(convo: Conversation) -> void:
	conversation = convo
	self.show()
	await show_conversation()
	self.hide()
	SignalBus.emit_signal("dialogue_finished")

func show_conversation() -> void:
	if conversation:
		for message in conversation.get_messages():
			await  write(message)
			await  wait_for_user_input()
			await get_tree().create_timer(0.1).timeout
	return

func wait_for_user_input() -> void:
	while not Input.is_action_just_released("skipdialogue"):
		await get_tree().process_frame
