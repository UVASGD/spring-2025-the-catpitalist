class_name Conversation extends Node

@onready var messages: Node = $Messages

var index:int
@export var debugname:String
@export var requests_item:bool = false
@export var request_item_id:int 
@export var requests_signal:bool = false
@export var request_signal_name:String
@export var locked:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	index = get_index()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_messages():
	return messages.get_children()

func can_show():
	if get_parent().get_parent() is NPC:
		if get_parent().get_parent().is_speaking:
			return false
