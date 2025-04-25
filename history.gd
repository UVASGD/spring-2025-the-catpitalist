extends Node


var happened = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func has_happened(event:String):
	return event.to_lower() in happened

func mark(event:String):
	happened.append(event.to_lower())
