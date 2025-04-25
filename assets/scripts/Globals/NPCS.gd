extends Node

@onready var npcs = {}
var npc_folder_path = "res://assets/scenes/npcs/"
var cache = {} #npc name, (convo index, next locked)
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

func load_cache(npc:NPC):
	if cache.has(npc.npc_name):
		npc.current_convo_index = cache[npc.npc_name][0]
		if cache[npc.npc_name][1] == true and cache[npc.npc_name][2] != null and not History.has_happened(cache[npc.npc_name][2]): #next convo locked
			npc.lock_current_convo()
		else:
			npc.unlock_current_convo()

func update_cache(npc:NPC):
	if not cache.has(npc.npc_name):
		cache[npc.npc_name] = [0, false, null]
	cache[npc.npc_name][0] = npc.current_convo_index
	if npc.get_next_convo() != null:
		cache[npc.npc_name][1] = npc.get_next_convo().locked
	if npc.get_current_convo() != null:
		if npc.get_current_convo().requests_signal:
			cache[npc.npc_name][2] = npc.get_current_convo().request_signal_name
