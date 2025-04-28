extends Control
@export var debug:bool
@onready var debugbutton: TextureButton = $TextureRect/debugbutton

func _ready() -> void:
	if debug:
		debugbutton.show()
func _on_start_pressed() -> void:
	SceneSwapper.change_scene("res://startcutscene.tscn")

func _on_continue_pressed() -> void:
	return

func _on_quit_pressed() -> void:
	get_tree().quit()

func hide_self():
	hide()
	for child:Control in $TextureRect.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_PASS 

func show_self():
	show()
	for child:Control in $TextureRect.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_STOP 


func _on_debugbutton_pressed() -> void:
	SceneSwapper.push("res://assets/scenes/worlds/testworld.tscn")
	pass # Replace with function body.
