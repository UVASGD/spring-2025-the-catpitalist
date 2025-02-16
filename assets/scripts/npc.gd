class_name NPC extends Interactable

@export var is_world_object: bool = false
@onready var convos: Node = $Convos
@export var npc_name:String
@export var exhaust_dialogue_text: String
@onready var exhaust_convo
@export_range(-1, 2, 0.1) var voice_pitch: float = 1
var current_convo_index = 0
var requested_item_id
var is_speaking = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	sign_messages()
	SignalBus.connect("item_given_to_npc", _on_item_given)
	if npc_name == "Blurbo":
		DebugManager.Blurbo = self
	setup_exhaust_dialogue()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_convos():
	return convos.get_children()

func sign_messages():
	for convo in get_convos():
		for message in convo.get_messages():
			message.speaker = npc_name

func get_next_convo():
	if is_world_object:
		return convos.get_child(0) # always use the same convo for world objects 
	if current_convo_index < convos.get_child_count():
		var convo = convos.get_child(current_convo_index)
		return convo

func get_old_convo():
	if current_convo_index > 0:
		var convo = convos.get_child(current_convo_index -1)
		return convo

func unlock_current_convo():
	if current_convo_index < convos.get_child_count():
		var convo = get_next_convo()
		if convo:
			convo.locked = false
			print("unlocked ", convo.debugname)

func lock_next_convo():
	if current_convo_index + 1 < convos.get_child_count():
		var convo = convos.get_child(current_convo_index +1)
		convo.locked = true
		print("locked ", convo.debugname)

func speak():
	if Dialogue.is_busy:
		return
	var convo:Conversation = get_next_convo()
	if convo:
		print(convo.debugname, " " + str(convo.locked))
		if convo.locked:
			convo = get_old_convo() # repeat last dialogue if next dialogue is locked 
			Dialogue.start_dialogue(convo)
			return
		elif convo.requests_item:
			requested_item_id = convo.request_item_id
			lock_next_convo()
		elif convo.requests_signal:
			SignalBus.connect(convo.request_signal_name, unlock_current_convo)
			lock_next_convo()

		Dialogue.start_dialogue(convo)
		current_convo_index += 1
	else:
		play_exhaust_dialogue()

func setup_exhaust_dialogue():
	var convo = Conversation.new()
	var message = Message.new()
	message.speaker = npc_name
	message.text = exhaust_dialogue_text
	var messages = Node.new()
	messages.name = "Messages"
	convo.add_child(messages)
	
	add_child(convo)
	convo.messages.add_child(message)
	convo.name = "Exhaust"
	exhaust_convo = convo
	
func play_exhaust_dialogue():
	Dialogue.start_dialogue(exhaust_convo)
	
func _on_item_given(item, npc):
	if item.ID == requested_item_id and npc == self:
		requested_item_id = null
		unlock_current_convo()
