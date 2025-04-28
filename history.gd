extends Node


var happened = []
# Called when the node enters the scene tree for the first time.


func has_happened(event:String):
	return event.to_lower() in happened

func mark(event:String):
	happened.append(event.to_lower())
