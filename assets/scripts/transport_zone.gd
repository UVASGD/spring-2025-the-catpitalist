class_name TransportZone extends Node2D
@export var path_to_new_scene:String
@onready var enterzone: Area2D = $enterzone
var can_transport # this gets automatically set to true on ready
# Called when the node enters the scene tree for the first time.


func _process(delta: float) -> void:
	print(can_transport)

func _on_enterzone_body_entered(body: Node2D) -> void:
	if body == PlayerData.player and can_transport and not SceneSwapper.busy:
		
		SceneSwapper.change_scene(path_to_new_scene)
	pass # Replace with function body.

func _on_visibility_changed() -> void:
	call_deferred("toggle_transport")
	pass

func toggle_transport():
	can_transport = not can_transport


func _on_tree_entered() -> void:
	can_transport = false
	pass # Replace with function body.
