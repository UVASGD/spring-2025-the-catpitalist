class_name Overworld_area extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Music.play_random()
	Music.set_mode(Music.INFINITE)
	setup_input()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass	

func get_save_data() -> Dictionary:
	var save_data = {}
	save_data["name"] = self.name
	save_data["children"] = []

	# Recursively get save data from children
	for child in self.get_children():
		if child.is_in_group("Saveable"):
			save_data["children"].append(child.get_save_data())
	return save_data
	
func load_save_data(save_data: Dictionary) -> void:
	for key in save_data["properties"].keys():
		self.set(key, save_data["properties"][key])

	# Recursively load save data into children
	for child_data in save_data["children"]:
		var child = self.get_node(child_data["name"])
		if child and child.is_in_group("Saveable"):
			child.load_save_data(child_data)

func setup_input():
	for npc in get_tree().get_nodes_in_group("NPCs"):
		if npc.has_method("setup_input"):
			npc.setup_input()
