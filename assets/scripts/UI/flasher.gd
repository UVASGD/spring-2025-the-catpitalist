extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
var delt = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delt += delta
	if delt > 1:
		if randi_range(0,2) == 2:
			var ind = randi_range(0,1)
			get_child(ind).show()
			await get_tree().create_timer(0.1).timeout
			get_child(ind).hide()
		delt = 0
	pass
