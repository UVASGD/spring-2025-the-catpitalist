class_name CutsceneMovement extends Node2D

@export var speed: float
@export var movement: Array[Vector2]
@export var start_time: float
@export var num_dialogue: int
@export var animation_override: String
@export var animation_override_speed: float = 1
var final_pos: Vector2
var curr_index = 0
	
func load_movement(npc_pos: Vector2):
	final_pos = self.position + npc_pos
	
	#add all movement points to a single array
	for i in self.get_children():
		movement.append(i.position + self.position + npc_pos)
		final_pos += i.position
