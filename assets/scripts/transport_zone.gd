class_name TransportZone extends Node2D
@export var toggles_on_signal: bool = false
@export var signal_name: String
@export var returns:bool = false
@export var path_to_new_scene:String
@onready var enterzone: Area2D = $enterzone
@export var can_transport:bool = false # this gets automatically set to true on ready
# Called when the node enters the scene tree for the first time.
@export var debug:bool = false
@export var loading_screen_path:String = "res://assets/scenes/ui/loadingscreen.tscn"


func _process(delta: float) -> void:
	if debug:
		print(can_transport)

func _on_enterzone_body_entered(body: Node2D) -> void:
	if body == PlayerData.player and can_transport and not SceneSwapper.busy:
		if toggles_on_signal:
			if not History.has_happened(signal_name):
				return
		if returns:
			SceneSwapper.call_deferred("pop_and_return")
		else:
			SceneSwapper.change_scene(path_to_new_scene, loading_screen_path)
	pass # Replace with function body.

func _on_visibility_changed() -> void:
	call_deferred("toggle_transport")
	pass

func toggle_transport():
	can_transport = not can_transport
	pass

func signaled():
	enterzone.monitoring = true
