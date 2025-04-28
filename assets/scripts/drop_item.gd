class_name DropItem extends Node2D

var real_item = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $DropItem/test:
		set_item($DropItem/test)
	#make_uptween()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

func set_item(item):
	real_item = item
	if item != null and item.get_parent() != $DropItem:
		$DropItem.add_child(item)


func give():
	$DropItem.remove_child(real_item)
	self.queue_free()
	return real_item
