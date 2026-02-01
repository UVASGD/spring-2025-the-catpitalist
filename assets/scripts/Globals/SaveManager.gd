extends Node

const SAVE_DIR = "user://saves/"
const MAX_SAVES = 5

var current_slot = -1

func _ready() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_" + str(slot) + ".dat"

func save_exists(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))

func get_all_saves() -> Array:
	var saves = []
	for i in range(MAX_SAVES):
		if save_exists(i):
			saves.append({"slot": i, "data": load_save_metadata(i)})
		else:
			saves.append({"slot": i, "data": null})
	return saves

func load_save_metadata(slot: int) -> Dictionary:
	if not save_exists(slot):
		return {}
	var file = FileAccess.open(get_save_path(slot), FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result == OK:
		var data = json.get_data()
		return {
			"day": int(data.get("day_num", 1)),
			"season": int(data.get("season", 0)),
			"money": int(data.get("player_money", 0)),
			"timestamp": data.get("timestamp", "")
		}
	return {}

func save_game(slot: int) -> bool:
	current_slot = slot
	var save_data = {}
	
	# Day & time info
	save_data["day_num"] = DayManager.day_num
	save_data["season"] = DayManager.season
	save_data["time"] = DayManager.time
	
	# Player data
	if PlayerData.player:
		save_data["player_money"] = PlayerData.player.money
		save_data["player_total_money"] = PlayerData.player.total_money_made
		save_data["player_held_item_index"] = PlayerData.player.held_item_index
		save_data["player_inventory"] = serialize_inventory(PlayerData.player.inventory)
		save_data["player_scale_x"] = PlayerData.player.alter_scale.x
		save_data["player_scale_y"] = PlayerData.player.alter_scale.y
		save_data["player_pos_x"] = PlayerData.player.global_position.x
		save_data["player_pos_y"] = PlayerData.player.global_position.y
		# Save pos_stack for proper scene exit positioning
		var pos_stack_data = []
		for pos in PlayerData.player.pos_stack:
			pos_stack_data.append({"x": pos.x, "y": pos.y})
		save_data["player_pos_stack"] = pos_stack_data
		print("[SAVE] Saving player scale: ", PlayerData.player.alter_scale)
		print("[SAVE] Saving player position: ", PlayerData.player.global_position)
		print("[SAVE] Saving pos_stack: ", PlayerData.player.pos_stack)
	
	# History / progression
	save_data["history"] = History.happened.duplicate()
	
	# NPC dialogue progress
	save_data["npc_cache"] = serialize_npc_cache()
	
	# Farm / plantable tiles
	save_data["farm_tiles"] = serialize_farm_tiles()
	
	# Current scene
	var current_scene = SceneSwapper.peek()
	if current_scene:
		save_data["scene_path"] = current_scene.scene_file_path
	
	# Timestamp
	save_data["timestamp"] = Time.get_datetime_string_from_system()
	
	var file = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved to slot ", slot)
		return true
	return false

func load_game(slot: int) -> bool:
	if not save_exists(slot):
		return false
	
	var file = FileAccess.open(get_save_path(slot), FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	
	if result != OK:
		return false
	
	var save_data = json.get_data()
	current_slot = slot
	
	# Restore day & time
	DayManager.day_num = int(save_data.get("day_num", 1))
	DayManager.season = int(save_data.get("season", 0))
	DayManager.time = float(save_data.get("time", (6 * 3600) / DayManager.TIME_SCALE))
	DayManager.prev_time = DayManager.time
	DayManager.update_day_state(DayManager.time)
	
	# Restore history
	History.happened = save_data.get("history", [])
	
	# Restore NPC cache
	deserialize_npc_cache(save_data.get("npc_cache", {}))
	
	# Store farm data for later restoration (when scene loads)
	_pending_farm_data = save_data.get("farm_tiles", {})
	_pending_player_data = {
		"money": save_data.get("player_money", 0),
		"total_money": save_data.get("player_total_money", 0),
		"held_item_index": save_data.get("player_held_item_index", 0),
		"inventory": save_data.get("player_inventory", []),
		"scale_x": save_data.get("player_scale_x", 1.0),
		"scale_y": save_data.get("player_scale_y", 1.0),
		"pos_x": save_data.get("player_pos_x", 0.0),
		"pos_y": save_data.get("player_pos_y", 0.0),
		"pos_stack": save_data.get("player_pos_stack", [])
	}
	_pending_scene_path = save_data.get("scene_path", "res://assets/scenes/worlds/tutorial.tscn")
	
	print("Game loaded from slot ", slot)
	return true

func get_load_scene_path() -> String:
	if _pending_scene_path != "":
		return _pending_scene_path
	return "res://assets/scenes/worlds/tutorial.tscn"

func load_saved_scene():
	is_loading_save = true
	var scene_path = get_load_scene_path()
	_load_target_scene = scene_path
	var overworld_path = "res://assets/scenes/worlds/tutorial.tscn"
	var is_indoors = scene_path.contains("indoors") or scene_path.contains("house")
	print("[LOAD] Scene path: ", scene_path, " is_indoors: ", is_indoors)
	
	if is_indoors:
		# Show loading screen during transition
		var loading_screen = load("res://assets/scenes/ui/loadingscreen.tscn").instantiate()
		get_tree().root.add_child(loading_screen)
		# Load overworld first (player hidden by loading screen)
		SceneSwapper.change_scene(overworld_path)
		await get_tree().create_timer(0.5).timeout
		# Push the indoor scene
		await SceneSwapper.push(scene_path)
		await get_tree().create_timer(0.2).timeout
		# Fade out loading screen
		await loading_screen.end()
		loading_screen.queue_free()
	else:
		SceneSwapper.change_scene(scene_path)

var _pending_farm_data = {}
var _pending_player_data = {}
var _pending_scene_path = ""
var is_loading_save = false
var _load_target_scene = ""  # The scene we're trying to load into

# Apply data that carries through player cloning (scale, inventory, money)
func apply_clonable_data():
	if PlayerData.player and not _pending_player_data.is_empty():
		PlayerData.player.money = int(_pending_player_data.get("money", 0))
		PlayerData.player.total_money_made = int(_pending_player_data.get("total_money", 0))
		PlayerData.player.held_item_index = int(_pending_player_data.get("held_item_index", 0))
		deserialize_inventory(_pending_player_data.get("inventory", []))
		var scale_x = float(_pending_player_data.get("scale_x", 1.0))
		var scale_y = float(_pending_player_data.get("scale_y", 1.0))
		print("[LOAD] Applying clonable data - scale: ", Vector2(scale_x, scale_y))
		PlayerData.player.alter_scale = Vector2(scale_x, scale_y)
		PlayerData.player.scale = Vector2(scale_x, scale_y)
		# Also apply pos_stack for proper cloning
		var pos_stack_data = _pending_player_data.get("pos_stack", [])
		if pos_stack_data.size() > 0:
			var restored_stack = []
			for pos_data in pos_stack_data:
				restored_stack.append(Vector2(float(pos_data["x"]), float(pos_data["y"])))
			PlayerData.player.pos_stack = restored_stack

func apply_player_data():
	if PlayerData.player and not _pending_player_data.is_empty():
		# Apply clonable data first
		apply_clonable_data()
		# Restore player position
		var pos_x = float(_pending_player_data.get("pos_x", 0.0))
		var pos_y = float(_pending_player_data.get("pos_y", 0.0))
		print("[LOAD] Restoring player position: ", pos_x, ", ", pos_y)
		if pos_x != 0.0 or pos_y != 0.0:
			PlayerData.player.global_position = Vector2(pos_x, pos_y)
			print("[LOAD] Player global_position set to: ", PlayerData.player.global_position)
		# Restore pos_stack for proper scene exit positioning
		var pos_stack_data = _pending_player_data.get("pos_stack", [])
		if pos_stack_data.size() > 0:
			var restored_stack = []
			for pos_data in pos_stack_data:
				restored_stack.append(Vector2(float(pos_data["x"]), float(pos_data["y"])))
			PlayerData.player.pos_stack = restored_stack
			print("[LOAD] Restored pos_stack: ", restored_stack)
		else:
			PlayerData.player.pos_stack = [PlayerData.player.global_position]
		_pending_player_data = {}
		is_loading_save = false
		_load_target_scene = ""
		# Ensure DayManager is unfrozen after loading
		DayManager.unfreeze()

func apply_farm_data(world_node: Node):
	if _pending_farm_data.is_empty():
		return
	
	var tiles = world_node.find_children("*", "PlantableTile", true, false)
	for tile in tiles:
		var tile_key = str(int(tile.global_position.x)) + "_" + str(int(tile.global_position.y))
		if _pending_farm_data.has(tile_key):
			var plant_data = _pending_farm_data[tile_key]
			restore_plant_on_tile(tile, plant_data)
	
	_pending_farm_data = {}

func serialize_inventory(inv: Array) -> Array:
	var result = []
	for item in inv:
		if item == null:
			result.append(null)
		else:
			result.append({
				"id": item.ID,
				"count": item.count
			})
	return result

func deserialize_inventory(inv_data: Array):
	if not PlayerData.player:
		return
	for i in range(min(inv_data.size(), PlayerData.player.inventory.size())):
		if inv_data[i] == null:
			PlayerData.player.inventory[i] = null
		else:
			var item_id = int(inv_data[i]["id"])
			if not Items.items.has(item_id):
				PlayerData.player.inventory[i] = null
				continue
			var item = Items.get_item(item_id)
			item.count = int(inv_data[i]["count"])
			PlayerData.player.inventory[i] = item

func serialize_npc_cache() -> Dictionary:
	var result = {}
	for npc_name in NPCS.cache.keys():
		result[npc_name] = NPCS.cache[npc_name].duplicate()
	return result

func deserialize_npc_cache(data: Dictionary):
	NPCS.cache.clear()
	for npc_name in data.keys():
		var cache_data = data[npc_name]
		# Convert convo index to int (JSON may parse as float)
		if cache_data is Array and cache_data.size() > 0:
			cache_data[0] = int(cache_data[0])
		NPCS.cache[npc_name] = cache_data

func serialize_farm_tiles() -> Dictionary:
	var result = {}
	var tiles = get_tree().get_nodes_in_group("crops")
	
	for scene in SceneSwapper.permloads.values():
		if scene.has_method("get_children"):
			var scene_tiles = scene.find_children("*", "PlantableTile", true, false)
			for tile in scene_tiles:
				if tile.held_plant != null:
					var tile_key = str(int(tile.global_position.x)) + "_" + str(int(tile.global_position.y))
					result[tile_key] = serialize_plant(tile.held_plant)
	
	# Also check current scene
	var current = SceneSwapper.peek()
	if current:
		var scene_tiles = current.find_children("*", "PlantableTile", true, false)
		for tile in scene_tiles:
			if tile.held_plant != null:
				var tile_key = str(int(tile.global_position.x)) + "_" + str(int(tile.global_position.y))
				result[tile_key] = serialize_plant(tile.held_plant)
	
	return result

func serialize_plant(plant: flower) -> Dictionary:
	return {
		"scene_path": plant.scene_file_path,
		"current_stage": plant.current_stage_index,
		"watered": plant.watered,
		"days_since_growth": plant.days_since_growth,
		"days_since_watered": plant.days_since_watered,
		"dead": plant.dead,
		"bloomed": plant.bloomed
	}

func restore_plant_on_tile(tile: PlantableTile, plant_data: Dictionary):
	if plant_data.is_empty():
		return
	
	var plant_scene = load(plant_data["scene_path"])
	if plant_scene:
		var plant = plant_scene.instantiate()
		plant.current_stage_index = int(plant_data.get("current_stage", 0))
		plant.watered = plant_data.get("watered", false)
		plant.days_since_growth = int(plant_data.get("days_since_growth", 0))
		plant.days_since_watered = int(plant_data.get("days_since_watered", 0))
		plant.dead = plant_data.get("dead", false)
		plant.bloomed = plant_data.get("bloomed", false)
		
		# Need to restore visual state after adding to scene
		tile.call_deferred("_restore_plant", plant, int(plant_data.get("current_stage", 0)))

func delete_save(slot: int) -> bool:
	if not save_exists(slot):
		return false
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.remove("save_" + str(slot) + ".dat")
		print("Deleted save in slot ", slot)
		return true
	return false

func get_season_name(season: int) -> String:
	match season:
		DayManager.SPRING: return "Spring"
		DayManager.SUMMER: return "Summer"
		DayManager.FALL: return "Fall"
		DayManager.WINTER: return "Winter"
	return "Unknown"
