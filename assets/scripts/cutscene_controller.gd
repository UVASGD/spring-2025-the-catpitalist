class_name CutsceneController extends Node2D

var moving = false
var currIndex: int

var time_elapsed = 0.0
var elapse_time = false

var npc_count = 0
var npcs_loaded = 0

var npcs_in_scene: Array[CutsceneNPC]

@export var hides_things:bool = false
@export var cutscene_length: int
@export var hidden_things:Array[Node2D]
func _ready() -> void:
	SignalBus.connect("dialogue_finished", _on_dialogue_finish)
	SignalBus.connect("new_dialogue", _on_dialogue)
	for i in get_children().filter(func(child): return child is CutsceneNPC):
		i.load_cutscene_npc()
		npcs_in_scene.append(i)
	elapse_time = true
	if hides_things:
		for node in hidden_things:
			node.call_deferred("hide")
	if $Player:
		align_player()
	
func align_player(): # assumes we want to use real player's location as a start point for fake player, to prevent odd position jumping when cutscene ends
	$Player.position = PlayerData.player.position

func _on_dialogue_finish() -> void:
	elapse_time = true
	
func _on_dialogue(_dialogue) -> void:
	elapse_time = false
	
func _physics_process(delta: float) -> void:
	if elapse_time:
		time_elapsed += delta
	PlayerData.player.actionable = false
	#iterate through each sprite in the cutscene
	for npc in npcs_in_scene:
		var anim_sprite = npc.sprite
		
		#default to idle animation at normal speed
		var animation_to_play = "idle"
		var animation_speed = 1.00
		
		#iterate through each moveset
		for move in npc.moves:
			if time_elapsed >= move.start_time:
				if elapse_time:
					#play dialogue if movement is finished, otherwise perform movement
					if move.curr_index == move.movement.size() && move.num_dialogue > 0:
						npc.speak()
						move.num_dialogue -= 1
					if move.curr_index < move.movement.size():
						var next_point = move.movement[move.curr_index]
						var direction = rad_to_deg((npc.position - next_point).angle())
						
						#set default directional animations
						if direction <= -45 && direction >= -135:
							anim_sprite.flip_h = false
							animation_to_play = "walk_down"
						elif direction <= -135 && direction >= 135:
							animation_to_play = "walk_right"
						elif direction <= 135 && direction >= 45:
							anim_sprite.flip_h = false
							animation_to_play = "walk_up"
						elif direction >= -45 && direction <= 45:
							animation_to_play = "walk_left"
						#speed of default movement animations (can/should be tweaked)
						animation_speed = move.speed/35
						
						#movement
						if npc.position != next_point:
							npc.position = npc.position.move_toward(next_point, delta*move.speed)
						else:
							move.curr_index += 1
						
				if move.animation_override:
					animation_to_play = move.animation_override
					animation_speed = move.animation_override_speed
		#correct directional animations if missing left or right animation
		if animation_to_play == "walk_left":
			if anim_sprite.sprite_frames.get_animation_names().has("walk_left"):
				anim_sprite.flip_h = false
			else:
				anim_sprite.flip_h = true
				animation_to_play = "walk_right"
		elif animation_to_play == "walk_right":
			if anim_sprite.sprite_frames.get_animation_names().has("walk_right"):
				anim_sprite.flip_h = false
			else:
				anim_sprite.flip_h = true
				animation_to_play = "walk_left"
			
		#execute animation
		anim_sprite.play(animation_to_play, animation_speed)
			
	if time_elapsed >= cutscene_length:
		end_cutscene()
		pass



func end_cutscene():
	if hides_things:
		for node in hidden_things:
			
			node.show()
	PlayerData.player.actionable = true
	queue_free()
	pass # Replace with function body.
