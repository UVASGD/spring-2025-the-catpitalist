@tool
extends EditorScript

func _run():
	var npc_folder = "res://assets/scenes/npcs/"
	var dir = DirAccess.open(npc_folder)
	if not dir:
		printerr("Failed to open NPC directory.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var entries = []
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var file_path = npc_folder + file_name
			var scene = load(file_path)
			if scene:
				var instance = scene.instantiate()
				var npc_name = instance.npc_name
				entries.append('"%s": "%s"' % [npc_name, file_path])
				instance.queue_free()
		file_name = dir.get_next()
	dir.list_dir_end()
	
	var dict_code = "@onready var npcs = {\n\t" + ",\n\t".join(entries) + "\n}\n"
	
	var save_path = "res://assets/scenes/npcs/npc_dict.gd"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(dict_code)
	file.close()
	
	print("NPC dict generated successfully!")
