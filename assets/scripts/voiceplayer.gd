extends Node2D
var letters = {}
var not_breathing = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		letters[child.name] = child
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func play(chara:String, npc:NPC):
	if chara == " " or chara == "." or chara == "?" or chara == "!":
		not_breathing = false
		await get_tree().create_timer(0.03).timeout
		not_breathing = true
		return
	var sound:AudioStreamPlayer = letters.get(chara)
	if sound:
		if npc.voice_pitch != -1: # npcs with no voice will have a voice pitch of -1
			sound.pitch_scale = npc.voice_pitch * 0.9
			sound.play()
			await get_tree().create_timer(0.25).timeout
			sound.stop()
