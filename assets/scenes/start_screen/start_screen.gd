extends Control

func _on_start_pressed() -> void:
	SceneSwapper.change_scene("res://assets/scenes/worlds/testworld.tscn")

func _on_continue_pressed() -> void:
	return

func _on_quit_pressed() -> void:
	get_tree().quit()
