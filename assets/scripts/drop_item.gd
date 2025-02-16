class_name DropItem extends Node2D

var real_item = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $test:
		set_item($test)
	make_uptween()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_item(item):
	real_item = item
	if item.get_parent() != self:
		add_child(item)


func give():
	remove_child(real_item)
	self.queue_free()
	return real_item

func _on_uptween_finish():
	make_downtween()
	return

func _on_downtween_finish():
	make_uptween()
	return

func make_uptween():
	var uptween = get_tree().create_tween()
	uptween.tween_property(self, "position", position + Vector2.UP * 5, 1)
	uptween.connect("finished", _on_uptween_finish)
	return

func make_downtween():
	var downtween = get_tree().create_tween()
	downtween.tween_property(self, "position", position + Vector2.DOWN * 5, 1)
	downtween.connect("finished", _on_downtween_finish)
	return
