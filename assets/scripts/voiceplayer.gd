extends Node2D
var letters = {}
var not_breathing = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		letters[child.name] = child
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play(char:String, npc:NPC):
	if char == " " or char == "." or char == "?" or char == "!":
		not_breathing = false
		await get_tree().create_timer(0.03).timeout
		not_breathing = true
		return
	var sound:AudioStreamPlayer2D = letters.get(char)
	if sound and not_breathing:
		if npc.voice_pitch != -1: # npcs with no voice will have a voice pitch of -1
			sound.pitch_scale = npc.voice_pitch
			sound.play()
			await get_tree().create_timer(0.15).timeout
			sound.stop()
