extends Node
@onready var debugmenu = null
var camera = null
var debug_menu_open = false
var Blurbo = null
var cooldown = false

#var cam_fired = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("cam_ready", _on_camera_ready)
	debugmenu = load("res://assets/scenes/debug/debugmenu.tscn").instantiate()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("debugmenu") and not debug_menu_open:
		open_menu()
		cooldown = true
		await get_tree().create_timer(0.3).timeout
		cooldown = false
		return
	if Input.is_action_just_released("closedebugmenu") and debug_menu_open:
		close_menu()
		cooldown = true
		await get_tree().create_timer(0.3).timeout
		cooldown = false
		return
	pass

func open_menu():
	debugmenu.enable()
	debug_menu_open = true
	return

func close_menu():
	debugmenu.disable()
	debug_menu_open = false
	return

func _on_camera_ready(cam):
	#if not cam_fired: # wait until the main scene's camera is loaded, since this script is autoload and might load before the camera is ready
	camera = cam
	debugmenu = load("res://assets/scenes/debug/debugmenu.tscn").instantiate()
	camera.add_child(debugmenu)
		#cam_fired = true
	return
