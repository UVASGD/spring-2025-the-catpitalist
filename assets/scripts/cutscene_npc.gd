class_name CutsceneNPC extends NPC

var moves: Array[CutsceneMovement]
var move_count = 0
var moves_loaded = 0

var last_pos: Vector2
				
func load_cutscene_npc() -> void:
	for i in get_children().filter(func(child): return child is CutsceneMovement):
		#make sure all movement nodes are invisible
		i.visible = false
		
		#initialize each movement
		i.load_movement(self.position)
		moves.append(i)
