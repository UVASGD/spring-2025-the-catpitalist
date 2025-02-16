extends Node

@onready var npcs = {}
var npc_folder_path = "res://assets/scenes/npcs/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_npcs()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_npcs():
	var dir = DirAccess.open(npc_folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var file_path = npc_folder_path + file_name
				var scene = load(file_path) as PackedScene
				if scene:
					var instance = scene.instantiate()
					var npc_name = instance.get("npc_name")
					if npc_name:
						npcs[npc_name] = scene
					instance.queue_free()  # Free the instance after getting the name
			file_name = dir.get_next()
		dir.list_dir_end()

func get_npc(speakername: String) -> PackedScene:
	return npcs.get(speakername, null)
