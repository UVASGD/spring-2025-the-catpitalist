class_name Indoors extends Node2D

@onready var spawnpoint: Node2D = $y_sorted/spawnpoint
var can_transport = true
@onready var exit: Area2D = $exit
@onready var seasonals = [$Spring_Summer, $Spring_Summer, $Fall, $Winter]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnpoint.add_child(PlayerData.clone_and_kill())
	if seasonals[DayManager.season]:
		seasonals[DayManager.season].show()
	if %water_entrance_closed and %water_entrance_open:
		if(History.has_happened("unlock_water")):
			_on_unlock_water()
		else:
			SignalBus.connect("unlock_water", _on_unlock_water)
	#PlayerData.player.reparent(spawnpoint)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_unlock_water():
	%water_entrance_closed.hide()
	%water_entrance_open.show()
