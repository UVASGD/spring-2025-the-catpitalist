extends Node

#stack of nodes
var permloads = {} # dict of scenes where the player can influence surroundings. key = scene name, value = save data for loading
var scene_stack = [] 
var busy = false

func _ready() -> void:
	if get_tree().current_scene.name in ["testworld", "StartScreen", "tutorial"]:
		scene_stack.push_front(get_tree().current_scene)

#func change_scene_from_path(old_scene, scene_path):
	#var progress = []
	#var loading_screen = load("res://assets/scenes/ui/loadingscreen.tscn").instantiate()
	#get_tree().current_scene.add_child(loading_screen)
	#await get_tree().create_timer(0.3).timeout
	#ResourceLoader.load_threaded_request(scene_path)
	#var status = ResourceLoader.load_threaded_get_status(scene_path)
	#ResourceLoader.load_threaded_get_status(scene_path, progress) # passing progress into the function should make it put the progress ratio into the progress array
	#while status != 3:
		#if status == 0 or status == 2:
			#print("error with resourceloader")
			#break
		#
		#status = ResourceLoader.load_threaded_get_status(scene_path)
		#ResourceLoader.load_threaded_get_status(scene_path, progress)
		#loading_screen.update(progress)
	#print("b")
	#var resource = ResourceLoader.load_threaded_get(scene_path)
		   #
	#get_tree().root.add_child(resource.instantiate())
	#loading_screen.end()

func private_change_scene(new_scene:Node, loading_screen_path:String="res://assets/scenes/ui/loadingscreen.tscn", pushing:bool = true): # not meant to be called by other scripts. how we actually change scenes under the hood
	var loading_screen = load(loading_screen_path).instantiate()
	get_tree().root.add_child(loading_screen)
	loading_screen.fake()
	if pushing:
		if peek().has_method("hide_self"):
			peek().hide_self()
		else:
			peek().hide()
		peek().process_mode = PROCESS_MODE_DISABLED
	
	if permloads.has(new_scene.name):
		new_scene = permloads[new_scene.name]
	if new_scene.get_parent() == get_tree().root:
		if new_scene.has_method("show_self"):
			new_scene.show_self()
		new_scene.show()
		new_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	else: 
		get_tree().root.add_child(new_scene)
	return

func change_scene(new_scene, loading_screen_path:String="res://assets/scenes/ui/loadingscreen.tscn"):
	cooldown() # for ease of use outside of this script, no need to know anything about the stack implementation
	push(new_scene, loading_screen_path)
	

func push(newscene, loading_screen_path:String="res://assets/scenes/ui/loadingscreen.tscn"):
	save_current() # may be unnecessary - test if this has performance impact
	
	if newscene is String:
		newscene = load(newscene)
	if newscene is PackedScene:
		newscene = newscene.instantiate()
	await private_change_scene(newscene, loading_screen_path)
	if newscene is Indoors or newscene is Overworld_area:
		Music.push(newscene.playlist_songs)
	scene_stack.push_front(newscene)
	return
	#newscene.set_process_input(true)
	#newscene.set_process_unhandled_input(true)
	#newscene.set_process_unhandled_key_input(true)

func pop(loading_screen_path:String="res://assets/scenes/ui/loadingscreen.tscn"):
	cooldown()
	save_current()
	var current_scene = scene_stack.pop_front()
	if current_scene is Indoors or current_scene is Overworld_area:
		Music.pop()
	#current_scene.set_process_input(false)
	#current_scene.set_process_unhandled_input(false)
	#current_scene.set_process_unhandled_key_input(false)
	get_tree().root.remove_child(current_scene)
	current_scene.queue_free()
	var returning_scene = peek()
	await private_change_scene(returning_scene, loading_screen_path, false)
	#returning_scene.set_process_input(true)
	#returning_scene.set_process_unhandled_input(true)
	#returning_scene.set_process_unhandled_key_input(true)
	return

func pop_and_return(context:Dictionary={},loading_screen_path:String="res://assets/scenes/ui/loadingscreen.tscn"):
	cooldown() # pos current scene and returns player to where they were before
	pop(loading_screen_path)
	var newplayer = PlayerData.clone_and_kill()
	#newplayer.flash_collision()
	newplayer.restore_pos()
	if peek().has_method("spawn_player"):
		peek().spawn_player(newplayer)
	else:
		peek().find_child("y_sorted").add_child(newplayer,true)
	if not context.is_empty():
		SignalBus.emit_signal("context",context)

func peek() -> Node:
	if scene_stack.size() < 1:
		return Node2D.new() # should do nothing
	return scene_stack[0]
	
func save_current():
	if peek().is_in_group("Saveable"):
		permloads[peek().name] = peek()

func cooldown():
	busy = true
	await get_tree().create_timer(1).timeout
	busy = false

func teleport_home():
	# Pop back to overworld first
	while not peek() is Overworld_area:
		pop_and_return()
	# Push into farmhouse and position player next to bed
	push("res://assets/scenes/farmhouse_indoors.tscn")
	await get_tree().process_frame
	# Position player to the left of the bed
	PlayerData.player.global_position = Vector2(860, 400)
	return

func reset_to_main_menu():
	# Unpause game
	get_tree().paused = false
	
	# Stop music and clear playlist
	await Music.fade_out()
	Music.playlist_stack.clear()
	
	# Clear all scenes from root except autoloads
	for child in get_tree().root.get_children():
		if child is CanvasLayer or child is Node2D or child is Control:
			if child.name != "SaveManager" and child.name != "SceneSwapper":
				child.queue_free()
	
	# Clear scene stack and permloads
	scene_stack.clear()
	permloads.clear()
	
	# Reset global state
	DayManager.day_num = 1
	DayManager.season = 0
	DayManager.time = (6 * 3600) / DayManager.TIME_SCALE
	DayManager.frozen = false
	History.happened.clear()
	NPCS.cache.clear()
	PlayerData.player = null
	SaveManager.current_slot = -1
	SaveManager._pending_player_data = {}
	SaveManager._pending_farm_data = {}
	SaveManager.is_loading_save = false
	
	# Load fresh start screen
	await get_tree().process_frame
	var start_screen = load("res://assets/scenes/start_screen/start_screen.tscn").instantiate()
	get_tree().root.add_child(start_screen)
	scene_stack.push_front(start_screen)
