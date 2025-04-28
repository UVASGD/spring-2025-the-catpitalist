extends "res://assets/scripts/npc.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if History.has_happened("alien_learn_english"):
		update_exhaust_dialogue("Hello dear friend. Please do the hurrying and find special metal")
	if History.has_happened("repair_rocket"):
		update_exhaust_dialogue("Dear friend may use rocket as dear friend pleases!")
	pass # Replace with function body.
