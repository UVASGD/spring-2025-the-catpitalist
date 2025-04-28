class_name Message extends Node

@export var text:String

#item id to trigger dialogue conditions based on having an item
@export var item_condition: int = -1
@export var item_amount: int = -1

enum ConditionAction {NOTHING, SKIP_IF_HAS, SKIP_IF_DOESNT_HAVE}
@export var condition_action: ConditionAction

@export var is_request: bool = false

var speaker:String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.
