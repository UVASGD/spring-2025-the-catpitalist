extends CanvasLayer

var arr = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if SceneSwapper.scene_stack:
		arr = SceneSwapper.scene_stack
		for i in $HBoxContainer.get_children(): # make labels
			$HBoxContainer.remove_child(i)
		for i in arr:
			var label = Label.new()
			if i is PackedScene:
				label.text = i.resource_path
			else:
				label.text = i.name
			$HBoxContainer.add_child(label)
	if PlayerData.player:
		for i in $VBoxContainer.get_children(): # make labels
			$VBoxContainer.remove_child(i)
		for i in PlayerData.player.pos_stack:
			var label = Label.new()
			label.text = str(i)
			$VBoxContainer.add_child(label)
		var curpos = Label.new()
		curpos.text = str(PlayerData.player.position)
		var lastpos = Label.new()
		lastpos.text = str(PlayerData.player.pos_stack[0])
		$VBoxContainer.add_child(lastpos)
		$VBoxContainer.add_child(curpos)
	pass
