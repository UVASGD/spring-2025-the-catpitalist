extends Control

func _on_start_pressed() -> void:
	SceneSwapper.change_scene("res://assets/scenes/worlds/tutorial.tscn")

func _on_continue_pressed() -> void:
	return

func _on_quit_pressed() -> void:
	get_tree().quit()

func hide_self():
	hide()
	for child:Control in $VBoxContainer.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_PASS 

func show_self():
	show()
	for child:Control in $VBoxContainer.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_STOP 
