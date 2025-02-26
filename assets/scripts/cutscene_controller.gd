class_name CutsceneController extends Node2D

var moving = false
var currIndex: int
var time_elapsed = 0.0

var npc_count = 0
var npcs_loaded = 0

var npcs_in_scene: Array[CutsceneNPC]
			
func _on_npc_finished_loading() -> void:
	if npc_count == 0:
		for i in get_children():
			if i is CutsceneNPC:
				npc_count += 1
	
	npcs_loaded += 1
	if npcs_loaded == npc_count:
		for i in get_children().filter(func(child): return child is CutsceneNPC):
			npcs_in_scene.append(i)
		moving = true
	
func _physics_process(delta: float) -> void:
	if moving:
		time_elapsed += delta
		for i in npcs_in_scene:
			for j in i.moves:
				if time_elapsed >= j.start_time:
					if j.curr_index < j.movement.size():
						var anim_sprite = i.get_node("Sprite2D")

						var next_point = j.movement[j.curr_index]
						var direction = rad_to_deg((i.position - next_point).angle())
						print(i.position, " ", j.final_pos)
						if i.position == j.final_pos:
							print("????")
							anim_sprite.play("idle")
							direction = -1000
						if direction <= -45 && direction >= -135:
							anim_sprite.flip_h = false
							anim_sprite.play("down", j.speed/20)
						elif (direction <= -135 || direction >= 135) && direction != -1000:
							if anim_sprite.sprite_frames.get_animation_names().has("right"):
								anim_sprite.flip_h = false
								anim_sprite.play("right", j.speed/20)
							else:
								anim_sprite.flip_h = true
								anim_sprite.play("left", j.speed/20)
						elif direction <= 135 && direction >= 45:
							anim_sprite.flip_h = false
							anim_sprite.play("up", j.speed/20)
						elif direction >= -45 && direction <= 45:
							if anim_sprite.sprite_frames.get_animation_names().has("left"):
								anim_sprite.flip_h = false
								anim_sprite.play("left", j.speed/20)
							else:
								anim_sprite.flip_h = true
								anim_sprite.play("right", j.speed/20)
						if i.position != next_point:
							i.position = i.position.move_toward(next_point, delta* j.speed)
						else:
							j.curr_index += 1
