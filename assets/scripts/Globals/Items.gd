extends Node

@onready var items = []
@onready var drop_items = []
@onready var dropitem = preload("res://assets/scenes/drop_item.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_items()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_items():
	var path ="res://assets/scenes/items/"
	var scene_loads = []

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tscn":
				var full_path = path.path_join(file_name)
				var file = FileAccess.open(full_path, FileAccess.READ)
				if file:
					var content = file.get_as_text()
					file.close()
					var id_value = extract_id_from_tscn(content)
					if id_value != null:
						scene_loads.append({"path": full_path, "id": id_value, "packedscene": load(full_path)})
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	# Sort the scenes by their ID
	scene_loads.sort_custom(scene_id_sort)
	
	items = scene_loads
	SignalBus.emit_signal("items_ready")


# Custom sort function
func scene_id_sort(a, b):
	return a["id"] < b["id"]

# Function to extract ID from tscn file content
func extract_id_from_tscn(content):
	var id_regex = RegEx.new()
	id_regex.compile('ID = (\\d+)')
	var match = id_regex.search(content)
	if match:
		return int(match.get_string(1))
	return null

func get_item(id):
	return items[id-1]["packedscene"].instantiate() #id - 1 to account for arrays starting at 0 

func clone(item): # will only copy over the count, anything else might need a more specific function
	var pack = items[item.ID-1]["packedscene"]
	var newitem = pack.instantiate()
	newitem.count = item.count 
	return newitem

func create_drop_item(item):
	if item:
		var newdrop = dropitem.instantiate()
		newdrop.set_item(item)
		return newdrop
