extends "res://assets/scripts/npc.gd"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var emo: Sprite2D = $Emo
@onready var final: Sprite2D = $final


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SignalBus.connect("emo_hazel", _turn_emo)
	SignalBus.connect("delete_water_robocat", _turn_final)
	if History.has_happened("emo_hazel"):
		_turn_emo()
	if History.has_happened("final_hazel"):
		_turn_final()
	pass # Replace with function body.




func _turn_emo():
	sprite_2d.hide()
	emo.show()

func _turn_final():
	emo.hide()
	final.show()
