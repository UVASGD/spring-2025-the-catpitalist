extends "res://assets/scripts/npc.gd"
@export var is_city:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if History.has_happened("delete_water_robocat"):
		if is_city:
			show()
		else:
			hide()
	else:
		if is_city:
			SignalBus.connect("delete_water_robocat", show)
			hide()
	pass # Replace with function body.
