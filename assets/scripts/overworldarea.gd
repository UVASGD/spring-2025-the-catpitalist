class_name Overworld_area extends Node2D

@export var playlist_songs: Array[String]
@export var debug:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Music.play_random()
	if debug:
		for i in range(1,22):
			PlayerData.player.inventory[i] = Items.get_item(i)
		Music.set_mode(Music.INFINITE)
		SignalBus.emit_signal("unlock_planting")
		History.mark("unlock_planting")
		History.mark("unlock_watering")
		SignalBus.emit_signal("unlock_watering")
	SignalBus.connect("beanstalk_grew", _on_beanstalk_grew)
	# Apply saved farm data if loading a game
	call_deferred("_apply_save_data")

func _apply_save_data():
	SaveManager.apply_farm_data(self)
	# Apply clonable data (scale, inventory) even when loading into indoor scene
	# This ensures the cloned player has correct data
	var my_path = scene_file_path
	if SaveManager._load_target_scene == "" or SaveManager._load_target_scene == my_path:
		SaveManager.apply_player_data()
	elif SaveManager.is_loading_save:
		SaveManager.apply_clonable_data()


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

func _on_beanstalk_grew():
	%beanstalk.show()
