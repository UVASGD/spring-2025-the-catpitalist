class_name Conversation extends Node

@onready var messages: Node = $Messages

var index:int
@export var debugname:String
@export var requests_item:bool = false
@export var request_item_id:int 
@export var requests_signal:bool = false
@export var request_signal_name:String
@export var locked:bool = false
@export var opens_shop:bool = false
@export var signals_on_finish:bool = false
@export var finish_signal:String
@export var is_exhaust:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	index = get_index()
	pass # Replace with function body.


	
func get_npc() -> NPC:
	if is_exhaust:
		return get_parent()
	return get_parent().get_parent()
	
func get_messages():
	return messages.get_children()

func can_show():
	if get_parent().get_parent() is NPC:
		if get_parent().get_parent().is_speaking:
			return false
