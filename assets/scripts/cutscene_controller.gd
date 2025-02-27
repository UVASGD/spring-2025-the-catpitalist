class_name CutsceneController extends Node2D

var moving = false
var currIndex: int

var time_elapsed = 0.0
var elapse_time = false
var last_dialogue = false

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
	if _dialogue.is_exhaust:
		last_dialogue = true
	else:
		last_dialogue = false
	elapse_time = false
	
func _physics_process(delta: float) -> void:
	if elapse_time:
		time_elapsed += delta
		for i in npcs_in_scene:
			var anim_sprite = i.get_node("Sprite2D")
			
			var animation_to_play = "idle"
			var animation_speed = 1.00
			
			for j in i.moves:
				if time_elapsed >= j.start_time:
					if j.curr_index == j.movement.size():
						if j.num_dialogue > 0:
							i.speak()
							j.num_dialogue -= 1
					if j.curr_index < j.movement.size():
						var next_point = j.movement[j.curr_index]
						var direction = rad_to_deg((i.position - next_point).angle())
						
						#directional animations
						if direction <= -45 && direction >= -135:
							anim_sprite.flip_h = false
							animation_to_play = "down"
						elif direction <= -135 || direction >= 135:
							if anim_sprite.sprite_frames.get_animation_names().has("right"):
								anim_sprite.flip_h = false
								animation_to_play = "right"
							else:
								anim_sprite.flip_h = true
								animation_to_play = "left"
						elif direction <= 135 && direction >= 45:
							anim_sprite.flip_h = false
							animation_to_play = "up"
						elif direction >= -45 && direction <= 45:
							if anim_sprite.sprite_frames.get_animation_names().has("left"):
								anim_sprite.flip_h = false
								animation_to_play = "left"
							else:
								anim_sprite.flip_h = true
								animation_to_play = "right"
						animation_speed = j.speed/20
						if i.position != next_point:
							i.position = i.position.move_toward(next_point, delta* j.speed)
						else:
							j.curr_index += 1
							
					if j.animation_override:
						animation_to_play = j.animation_override
						animation_speed = 1
			anim_sprite.play(animation_to_play, animation_speed)
	#conditions when time isn't moving (during dialogue)
	else:
		for i in npcs_in_scene:
			#play idle animation by default at normal speed
			var animation_to_play = "idle"
			var animation_speed = 1.00
			
			var anim_sprite = i.get_node("Sprite2D")
			
			#play override animation if it's there
			for j in i.moves:
				if j.animation_override && time_elapsed >= j.start_time:
					animation_to_play = j.animation_override
					animation_speed = 1
			
			anim_sprite.play(animation_to_play, animation_speed)
			
	if time_elapsed >= cutscene_length:
		pass
