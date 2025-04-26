class_name NPC extends Interactable

@export var is_world_object: bool = false
@onready var convos: Node = $Convos
@export var npc_name:String
@export var exhaust_dialogue_text: String
@onready var exhaust_convo
@export_range(-1, 2, 0.1) var voice_pitch: float = 1
@export var shopkeeper = false
@export var current_convo_index = 0
@export var portrait_path:String
var requested_item_id
var is_speaking = false
@onready var hitbox: Area2D = $hitbox
var inventory = [] # list of items the NPC can sell 
@export var has_idle_walk:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	sign_messages()
	SignalBus.connect("item_given_to_npc", _on_item_given)
	if npc_name == "Blurbo":
		DebugManager.Blurbo = self
	setup_exhaust_dialogue()
	if has_idle_walk:
		$AnimationPlayer2D.play("idle_walk")
	NPCS.load_cache(self)
	if npc_name == "Loan Shark": # i know this sucks
		SignalBus.connect("start_loan_shark_animation", play_loanshark_anim)
	pass # Replace with function body.

func _process(delta: float) -> void:
	
	return 

func get_convos():
	if convos:
		return convos.get_children()

func sign_messages():
	if get_convos() != null:
		for convo in get_convos():
			for message in convo.get_messages():
				message.speaker = npc_name
func get_current_convo():
	if is_world_object:
		return convos.get_child(0) # always use the same convo for world objects 
	if current_convo_index -1 > 0:
		var convo = convos.get_child(current_convo_index)
		return convo

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

func lock_current_convo():
	if current_convo_index < convos.get_child_count():
		var convo = get_next_convo()
		if convo:
			convo.locked = true
			print("unlocked ", convo.debugname)
func unlock_next_convo():
	if current_convo_index + 1 < convos.get_child_count():
		var convo = convos.get_child(current_convo_index + 1)
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
			if convo:
				Dialogue.start_dialogue(convo)
			else:
				play_exhaust_dialogue()
			NPCS.update_cache(self)
			return
		elif convo.requests_item:
			requested_item_id = convo.request_item_id
			lock_next_convo()
		elif convo.requests_signal:
			if not History.has_happened(convo.request_signal_name):
				SignalBus.connect(convo.request_signal_name, unlock_current_convo)
				lock_next_convo()
		
		Dialogue.start_dialogue(convo)
		await SignalBus.dialogue_finished
		if convo.signals_on_finish:
			SignalBus.emit_signal(convo.finish_signal)
			History.mark(convo.finish_signal)
		current_convo_index += 1
	else:
		play_exhaust_dialogue()
	NPCS.update_cache(self)

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
	convo.is_exhaust = true
	if shopkeeper:
		convo.opens_shop = true
	exhaust_convo = convo
	
func play_exhaust_dialogue():
	Dialogue.start_dialogue(exhaust_convo)
	
func _on_item_given(item, npc):
	if item.ID == requested_item_id and npc.npc_name == self.npc_name:
		requested_item_id = null
		unlock_next_convo()
		speak()

func open_shop():
	UI.open_shop(inventory, self)

func get_portrait():
	if portrait_path:
		return load(portrait_path)
	else:
		return load("res://assets/sprites/NPC portraits/default_portrait.png")

func play_loanshark_anim():
	$AnimationPlayer.play("animation")
