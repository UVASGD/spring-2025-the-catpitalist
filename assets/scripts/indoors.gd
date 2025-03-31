class_name Indoors extends Node2D

@onready var spawnpoint: Node2D = $y_sorted/spawnpoint
var can_transport = true
@onready var exit: Area2D = $exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnpoint.add_child(PlayerData.clone_and_kill())
	#PlayerData.player.reparent(spawnpoint)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
