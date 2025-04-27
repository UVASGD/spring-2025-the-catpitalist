extends Node

#stack of nodes
var permloads = {} # dict of scenes where the player can influence surroundings. key = scene name, value = save data for loading
var scene_stack = [] 
var busy = false

func _ready() -> void:
	var cur = get_tree().current_scene.name
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
	if scene_stack.size() > 0:
		var current_scene = peek()
		#current_scene.set_process_input(false)
		#current_scene.set_process_unhandled_input(false)
		#current_scene.set_process_unhandled_key_input(false)
	
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
		Music.pop(current_scene.playlist_songs)
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
	peek().add_child(newplayer,true)
	if not context.is_empty():
		SignalBus.emit_signal("context",context)

func peek():
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
