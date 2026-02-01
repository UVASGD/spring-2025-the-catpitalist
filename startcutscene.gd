extends Control

var skipped = false

func _ready() -> void:
	$AnimationPlayer.play("new_animation")
	await $AnimationPlayer.animation_finished
	if not skipped:
		end_cutscene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skipdialogue") and not skipped:
		skip_cutscene()

func skip_cutscene():
	skipped = true
	$AnimationPlayer.stop()
	$AudioStreamPlayer.stop()
	end_cutscene()

func end_cutscene():
	SceneSwapper.change_scene("res://assets/scenes/worlds/tutorial.tscn")
