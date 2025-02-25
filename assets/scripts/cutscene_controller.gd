class_name CutsceneController extends Node2D

var moving = false
var currIndex: int

func _on_movement_finished_loading() -> void:
	currIndex = 0
	moving = true
	for i in range(0,$NPC/movement.movement.size()):
		$NPC/movement.movement[i] += $NPC.position
	
func _physics_process(delta: float) -> void:
	if moving:	
		var x = $NPC/movement
		
		$NPC/Sprite2D.play("idle")
		if currIndex < $NPC/movement.movement.size():
			if $NPC.position != x.movement[currIndex]:
				print(str($NPC.position,", ",x.movement[currIndex]))
				$NPC.position = $NPC.position.move_toward(x.movement[currIndex], delta * x.speed)
			else:
				currIndex += 1
		else:
			moving = false
