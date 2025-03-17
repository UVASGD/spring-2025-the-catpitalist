extends Indoors

var second_cutscene = preload("res://assets/scenes/cutscenes/tut_cutscene_2.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SignalBus.connect("mom_dialogue_done", transition)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func transition():
	$AnimationPlayer.play("transition")
	await get_tree().create_timer(2.5).timeout
	grow_player()
	var newcutscene = second_cutscene.instantiate()
	newcutscene.hides_things = true
	newcutscene.hidden_things.append($y_sorted/normaldad)
	$y_sorted/normaldad.show()
	await $AnimationPlayer.animation_finished
	$y_sorted.add_child(newcutscene)
	
func grow_player():
	PlayerData.player.animated_sprite.scale = Vector2(1,1)
	PlayerData.player.alter_scale = Vector2(1,1)
	return
