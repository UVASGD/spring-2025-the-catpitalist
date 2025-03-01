class_name Building extends Sprite2D
@export var path_to_indoor_scene:String
@onready var enterzone: Area2D = $enterzone
var can_transport= false # this gets automatically set to true on ready
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enterzone_body_entered(body: Node2D) -> void:
	if body == PlayerData.player and can_transport and not SceneSwapper.busy:
		
		SceneSwapper.change_scene(path_to_indoor_scene)
	pass # Replace with function body.

func _on_visibility_changed() -> void:
	can_transport = not can_transport
	pass
