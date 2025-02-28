extends Node

#stack of nodes
var permloads = {} # dict of scenes where the player can influence surroundings. key = scene name, value = save data for loading
var scene_stack = [] 

func _ready() -> void:
	var cur = get_tree().current_scene.name
	if get_tree().current_scene.name == "testworld" or get_tree().current_scene.name == "StartScreen":
		scene_stack.push_front(get_tree().current_scene)

func change_scene_from_path(old_scene, scene_path):
	var progress = []
	var loading_screen = load("res://assets/scenes/ui/loadingscreen.tscn").instantiate()
	get_tree().current_scene.add_child(loading_screen)
	await get_tree().create_timer(0.3).timeout
	ResourceLoader.load_threaded_request(scene_path)
	var status = ResourceLoader.load_threaded_get_status(scene_path)
	ResourceLoader.load_threaded_get_status(scene_path, progress) # passing progress into the function should make it put the progress ratio into the progress array
	while status != 3:
		if status == 0 or status == 2:
			print("error with resourceloader")
			break
		
		status = ResourceLoader.load_threaded_get_status(scene_path)
		ResourceLoader.load_threaded_get_status(scene_path, progress)
		loading_screen.update(progress)
	print("b")
	var resource = ResourceLoader.load_threaded_get(scene_path)
		   
	get_tree().root.add_child(resource.instantiate())
	loading_screen.end()

func private_change_scene(new_scene:Node): # not meant to be called by other scripts. how we actually change scenes under the hood
	var loading_screen = load("res://assets/scenes/ui/loadingscreen.tscn").instantiate()
	get_tree().current_scene.add_child(loading_screen)
	loading_screen.fake()
	peek().hide()
	get_tree().current_scene = new_scene
	if permloads.has(new_scene.name) and new_scene.is_in_group("Saveable"):
		new_scene.load(permloads[new_scene.name])
	if new_scene.get_parent() == get_tree().root:
		new_scene.show()
	else: 
		get_tree().root.add_child(new_scene)
	return

func change_scene(new_scene): # for ease of use outside of this script, no need to know anything about the stack implementation
	push(new_scene)

func push(newscene):
	save_current() # may be unnecessary - test if this has performance impact
	if scene_stack.size() > 0:
		var current_scene = peek()
		#current_scene.set_process_input(false)
		#current_scene.set_process_unhandled_input(false)
		#current_scene.set_process_unhandled_key_input(false)
	
	if newscene is String:
		newscene = load(newscene)
	newscene = newscene.instantiate()
	await private_change_scene(newscene)
	scene_stack.push_front(newscene)
	#newscene.set_process_input(true)
	#newscene.set_process_unhandled_input(true)
	#newscene.set_process_unhandled_key_input(true)

func pop():
	save_current()
	var current_scene = scene_stack.pop_front()
	#current_scene.set_process_input(false)
	#current_scene.set_process_unhandled_input(false)
	#current_scene.set_process_unhandled_key_input(false)
	get_tree().root.remove_child(scene_stack.pop_front())
	var returning_scene = peek()
	await private_change_scene(returning_scene)
	#returning_scene.set_process_input(true)
	#returning_scene.set_process_unhandled_input(true)
	#returning_scene.set_process_unhandled_key_input(true)
	return

func peek():
	if scene_stack.size() < 1:
		return Node2D.new() # should do nothing
	return scene_stack[-1]
	
func save_current():
	if peek().is_in_group("Saveable"):
		permloads[peek().name] = peek().get_savedata()
