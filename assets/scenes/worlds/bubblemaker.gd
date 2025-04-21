extends CanvasLayer

@onready var bubbleholder: Control = $Control
@onready var bubbletimer: Timer = $bubbletimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bubbletimer_timeout() -> void:
	bubbleholder.get_children().pick_random().play("default")
	pass # Replace with function body.
