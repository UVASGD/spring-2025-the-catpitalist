class_name CutsceneMovement extends Node2D

@export var speed: float
@export var movement: Array[Vector2]
@export var start_time: float
var final_pos: Vector2
var curr_index = 0
signal finished_loading(move: CutsceneMovement)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	final_pos = self.position
	
	#add all movement points to a single array
	for i in self.get_children():
		movement.append(i.position + self.position)
		final_pos += i.position
		
	print(movement[movement.size() - 1])
	print(final_pos)
	#tell NPC to add movement
	print("eeee")
	finished_loading.emit(self)
