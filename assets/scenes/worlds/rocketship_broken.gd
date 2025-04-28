extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if History.has_happened("repair_rocket"):
		queue_free()
	pass # Replace with function body.
