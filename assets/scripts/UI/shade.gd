extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("dawn_end", _on_daytime)
	SignalBus.connect("dusk_start", _on_nighttime)
	SignalBus.connect("midnight_debug", _on_midnight)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_daytime():
	animation_player.play("day")
	return

func _on_nighttime():
	animation_player.play("night")
	return
func _on_midnight():
	animation_player.play("night")
