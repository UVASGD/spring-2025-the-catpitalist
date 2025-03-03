extends Overworld_area
@export var play_tutorial = true
func _ready() -> void:
	super()
	SignalBus.connect("spawn_seeds", spawn_seeds)
	SignalBus.connect("context", _on_context)
	return

func spawn_seeds():
	var seeds = Items.get_item(2)
	var drop = Items.create_drop_item(seeds)
	$seedspawnpoint.add_child(drop)

func _on_context(context:Dictionary):
	if context["recipient"] == "farm":
		$AnimationPlayer.play_animation(context["animation"])
		return

func grow_player():
	PlayerData.player.scale = Vector2(1,1)
	PlayerData.player.alter_scale = Vector2(1,1)
	return


func _on_dadkiller_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(1).timeout
	if $y_sorted/TutDad != null:
		$y_sorted/TutDad.queue_free()
	pass # Replace with function body.
