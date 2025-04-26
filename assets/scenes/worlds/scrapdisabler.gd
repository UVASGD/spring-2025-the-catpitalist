extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if History.has_happened("scrappy_shop_closed"):
		get_parent().enterzone.monitoring = false
	if History.has_happened("unlock_scrappy_shop_again"):
		get_parent().enterzone.monitoring = true
	pass
