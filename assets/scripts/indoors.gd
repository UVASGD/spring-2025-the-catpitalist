class_name Indoors extends Node2D

@onready var spawnpoint: Node2D = $spawnpoint
var can_transport = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnpoint.add_child(PlayerData.clone_and_kill())
	#PlayerData.player.reparent(spawnpoint)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("can transport: ", can_transport)
	if can_transport and body is Player and not SceneSwapper.busy:
		can_transport = not can_transport
		body.flash_collision()
		SceneSwapper.call_deferred("pop_and_return")
		#SceneSwapper.pop_and_return()
		print("transporting")
		
	pass
