extends Node

var shops = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_shops()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_shops():
	var dir = DirAccess.open("res://assets/scenes/ui/shops/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var file_path = "res://assets/scenes/ui/shops/" + file_name
				var packed = load(file_path)
				var temp = packed.instantiate()
				shops[temp.npc_name] = packed
				temp.queue_free()
			file_name = dir.get_next()
		dir.list_dir_end()
	return

func open_shop(inventory:Array, npc:NPC):
	print("opening shop")
	var packed = shops[npc.npc_name]
	var shop:Shop = packed.instantiate()
	shop.inventory = inventory
	SceneSwapper.change_scene(packed)
	return

func close_shop():
	SceneSwapper.pop()
