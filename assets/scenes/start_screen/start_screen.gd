extends Control
@export var debug:bool
@onready var title_animation_player: AnimationPlayer = $bg/title/AnimationPlayer
@onready var animation_player: AnimationPlayer = $bg/TextureButton/AnimationPlayer

func _ready() -> void:
	title_animation_player.connect("animation_finished", _on_title_ready)
	
func _on_start_pressed() -> void:
	$bg/TextureButton.disabled = true
	$AudioStreamPlayer2.playing = true
	
	await $AudioStreamPlayer2.finished
	$AnimationPlayer.play("end")
	await $AnimationPlayer.animation_finished
	SceneSwapper.change_scene("res://startcutscene.tscn")
	$AudioStreamPlayer.playing = false
	
func _on_continue_pressed() -> void:
	return

func _on_quit_pressed() -> void:
	get_tree().quit()

func hide_self():
	hide()
	for child:Control in $bg.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_PASS 
	$shading.mouse_filter = Control.MOUSE_FILTER_PASS 
func show_self():
	show()
	for child:Control in $bg.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_STOP 
	$shading.mouse_filter = Control.MOUSE_FILTER_PASS 
	$bg/TextureButton.disabled = false

func _on_debugbutton_pressed() -> void:
	SceneSwapper.push("res://assets/scenes/worlds/testworld.tscn")
	pass # Replace with function body.

func _on_title_ready(animation):
	animation_player.connect("animation_finished", play_button_sway)
	animation_player.play("new_animation_2")
	
func play_button_sway(animation):
	animation_player.play("new_animation")
