extends "res://assets/scripts/npc.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if History.has_happened("chubbs_move"):
		position.x -= 100
	SignalBus.connect("chubbs_move", on_chubbs_move)
	#if History.has_happened("start_loanshark_quest"):
		#if NPCS.cache.has(npc_name):
			#current_convo_index = max(NPCS.cache[npc_name][0],1) # if player has not yet done the first convo, skip to second
		#else:
			#current_convo_index =1 
		#convos.get_child(1).locked = false
	
	pass # Replace with function body.

func on_chubbs_move():
	$AnimationPlayer.play("move")
