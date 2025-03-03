extends CanvasLayer
var cam = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam = get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_backtogame_pressed() -> void:
	cam.close_pause()
	pass # Replace with function body.


func _on_quitgame_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
