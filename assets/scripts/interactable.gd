class_name Interactable extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $hitbox:
		$hitbox.connect("input_event", _on_area_2d_input_event)
	else:
		print("interactable has no hitbox: ",self)
	pass # Replace with function body.




func interact():
	print("interacted")
	SignalBus.emit_signal("interact", self)
	return

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void: # when this plant is clicked on 
	if event.is_action_pressed("leftclick"):
		var overlaps = $hitbox.get_overlapping_areas()
		for area in overlaps:
			if area is Player_interact_zone:
				interact()
				break
	pass # Replace with function body.
