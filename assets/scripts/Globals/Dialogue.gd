extends Node
@onready var audio_stream_player_2d= preload("res://assets/scenes/voiceplayer.tscn").instantiate()

var is_busy = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("dialogue_finished", _on_dialogue_finished)
	add_child(audio_stream_player_2d)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_dialogue(convo:Conversation):
	is_busy = true
	SignalBus.emit_signal("new_dialogue", convo)

func _on_dialogue_finished():
	is_busy = false

func play_voice(letter, speakername):
	var npc = NPCS.get_npc(speakername).instantiate()
	audio_stream_player_2d.play(letter, npc)
	
