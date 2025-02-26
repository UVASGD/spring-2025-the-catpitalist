class_name CutsceneNPC extends NPC

var moves: Array[CutsceneMovement]
var move_count = 0
var moves_loaded = 0
signal finished_loading

func _ready() -> void:
	super()

func _on_movement_finished_loading(move: CutsceneMovement) -> void:
	if move_count == 0:
		for i in get_children():
			if i is CutsceneMovement:
				move_count += 1

	moves.append(move)
	moves_loaded += 1
	for i in range(0, move.movement.size()):
		move.movement[i] += self.position
	if moves_loaded == move_count:
		self.finished_loading.emit()
