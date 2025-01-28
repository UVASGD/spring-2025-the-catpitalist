extends Node

@onready var cam = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("openinventory"):
		cam.open_inv()
	return
