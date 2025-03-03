class_name CutsceneController extends Node2D

var moving = false
var currIndex: int

var time_elapsed = 0.0
var elapse_time = false

var npc_count = 0
var npcs_loaded = 0

var npcs_in_scene: Array[CutsceneNPC]

@export var cutscene_length: int

func _ready() -> void:
	SignalBus.connect("dialogue_finished", _on_dialogue_finish)
	SignalBus.connect("new_dialogue", _on_dialogue)
	for i in get_children().filter(func(child): return child is CutsceneNPC):
		i.load_cutscene_npc()
		npcs_in_scene.append(i)
	elapse_time = true
		
func _on_dialogue_finish() -> void:
	elapse_time = true
	
func _on_dialogue(_dialogue) -> void:
	elapse_time = false
	
func _physics_process(delta: float) -> void:
	if elapse_time:
		time_elapsed += delta
	
	#iterate through each sprite in the cutscene
	for i in npcs_in_scene:
		#find animated sprite
		var anim_sprite = null
		for j in i.get_children():
			if j is AnimatedSprite2D:
				anim_sprite = j
				break
		
		#default to idle animation at normal speed
		var animation_to_play = "idle"
		var animation_speed = 1.00
		
		#iterate through each moveset
		for j in i.moves:
			if time_elapsed >= j.start_time:
				if elapse_time:
					#play dialogue if movement is finished, otherwise perform movement
					if j.curr_index == j.movement.size() && j.num_dialogue > 0:
						i.speak()
						j.num_dialogue -= 1
					if j.curr_index < j.movement.size():
						var next_point = j.movement[j.curr_index]
						var direction = rad_to_deg((i.position - next_point).angle())
						
						#set default directional animations
						if direction <= -45 && direction >= -135:
							anim_sprite.flip_h = false
							animation_to_play = "walk_down"
						elif direction <= -135 || direction >= 135:
							animation_to_play = "walk_right"
						elif direction <= 135 && direction >= 45:
							anim_sprite.flip_h = false
							animation_to_play = "walk_up"
						elif direction >= -45 && direction <= 45:
							animation_to_play = "walk_left"
						#speed of default movement animations (can/should be tweaked)
						animation_speed = j.speed/35
						
						#movement
						if i.position != next_point:
							i.position = i.position.move_toward(next_point, delta*j.speed)
						else:
							j.curr_index += 1
						
				if j.animation_override:
					animation_to_play = j.animation_override
					animation_speed = j.animation_override_speed
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
		pass
