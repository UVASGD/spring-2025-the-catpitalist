extends Control
@export var debug:bool
@onready var title_animation_player: AnimationPlayer = $bg/title/AnimationPlayer
@onready var animation_player: AnimationPlayer = $bg/TextureButton/AnimationPlayer

var save_select_scene = preload("res://assets/scenes/ui/save_select.tscn")

func _ready() -> void:
	title_animation_player.connect("animation_finished", _on_title_ready)
	update_load_button_visibility()
	
func update_load_button_visibility():
	var has_saves = false
	for i in range(SaveManager.MAX_SAVES):
		if SaveManager.save_exists(i):
			has_saves = true
			break
	$bg/LoadButton.visible = has_saves

func _on_start_pressed() -> void:
	$bg/TextureButton.disabled = true
	# Open save slot selection for new game
	var save_select = save_select_scene.instantiate()
	add_child(save_select)
	save_select.set_mode("new_game")
	save_select.save_selected.connect(_on_new_game_slot_selected)
	save_select.closed.connect(_on_save_select_closed)

func _on_new_game_slot_selected(slot: int):
	$AudioStreamPlayer2.playing = true
	await $AudioStreamPlayer2.finished
	$AnimationPlayer.play("end")
	await $AnimationPlayer.animation_finished
	SceneSwapper.change_scene("res://startcutscene.tscn")
	$AudioStreamPlayer.playing = false

func _on_save_select_closed():
	$bg/TextureButton.disabled = false

func _on_load_pressed() -> void:
	var save_select = save_select_scene.instantiate()
	add_child(save_select)
	save_select.set_mode("load")
	
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


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
