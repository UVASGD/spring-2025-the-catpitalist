class_name Player extends CharacterBody2D

@export var speed := 200
@export var alter_scale:Vector2 = Vector2(1,1)
@onready var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var money = 0
var total_money_made= 0
var actionable = false
var inventory = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
var inv_showing = false
var inv_cooldown = false
var can_pickup = true
var held_item_index = 0
var last_pos_timer
var pos_stack = []
var progression = {
	800: "scrappy_shop_closed",
	1000: "made_1000",
	10000: "made_10000",
	100000: "made_100000",
	1000000: "made_1000000",
	10000000: "made_10000000",
	100000000: "made_100000000",
	
}
var is_clone = false  # Set by clone() to skip tutorial setup

func _ready() -> void:
	scale = alter_scale
	flash_actionable()
	SignalBus.connect("interact", interact)
	SignalBus.connect("gift_100", get_100)
	SignalBus.connect("give_suit", get_suit)
	SignalBus.connect("give_strange_piece", get_strange_piece)
	SignalBus.connect("give_rainbow_seed", get_bean)
	#SignalBus.connect("items_ready", _on_items_ready)
	# Only give tutorial watercan to fresh players (not clones)
	if not is_clone:
		inventory[8] = Items.get_item(1) # tutorial watercan
	#inventory[9] = Items.get_item(4) #scythe
	#inventory[1] = Items.get_item(1) #stack test
	#inventory[2] = Items.get_item(2) # seeds test
	#inventory[3] = Items.get_item(23) # loan shark suit
	SignalBus.emit_signal("player_ready", self)
	last_pos_timer = Timer.new()
	last_pos_timer.wait_time = 0.1
	last_pos_timer.connect("timeout", on_pos_timer_timeout)
	add_child(last_pos_timer)
	last_pos_timer.start()
	pos_stack.push_front(position)
	flash_collision()

func get_bean():
	add_to_inv(Items.get_item(25))

func fall_asleep(exhausted=true):
	print("[SLEEP] fall_asleep called, exhausted=", exhausted)
	print("[SLEEP] animation_player valid: ", animation_player != null)
	print("[SLEEP] player in tree: ", is_inside_tree())
	actionable = false
	if exhausted:
		animation_player.play("sleep_exhausted")
		await get_tree().create_timer(3).timeout
	else:
		animation_player.play("sleep")
		await get_tree().create_timer(3).timeout
	print("[SLEEP] animation finished")
	actionable = true
	return

func check_money(): # called when the player gains money in any way
	for val in progression.keys():
		if total_money_made >= val:
			SignalBus.emit(progression[val])
			History.mark(progression[val])
func get_100():
	money += 100
	total_money_made += 100
	check_money()

func flash_collision():
	if collision_shape_2d == null:
		return
	collision_shape_2d.disabled = true
	await get_tree().create_timer(0.5).timeout
	collision_shape_2d.disabled = false

func flash_actionable():
	actionable = false
	await get_tree().create_timer(0.5).timeout
	actionable = true
func _physics_process(_delta):
	if actionable:
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction * speed
		move_and_slide()

func _on_items_ready():

	inventory[0] = Items.get_item(1) # debug watercan 
	SignalBus.emit_signal("player_ready", self)

func restore_pos():
	if pos_stack.size() >= 2:
		pos_stack.pop_front()
		position = pos_stack.pop_front() # call twice because push happens twice per cloning
	elif pos_stack.size() == 1:
		position = pos_stack.pop_front()

func get_suit():
	add_to_inv(Items.get_item(23))
	return

func get_strange_piece():
	add_to_inv(Items.get_item(24))
	return

func drop(item, from_harvest = false):
	if item != null:
		if not item is DropItem and item.ID == 1:
			SignalBus.emit_signal("tutorial_dropped")
		get_tree().root.add_child(item)
		item.global_position = position
		# Only apply pickup cooldown for manually dropped items, not harvested ones
		if not from_harvest:
			can_pickup = false
			await get_tree().create_timer(3).timeout
			can_pickup = true

func pickup(item:DropItem):
	if can_pickup and item != null:
		SignalBus.emit_signal("tutorial_pickup")
		add_to_inv(item.give())
		
func find_available_inv_slot(item):
	for i in range(0,24):
		if inventory[i] == null:
			return i
		elif inventory[i].ID == item.ID:
			if inventory[i].stackable and inventory[i].count + item.count <= item.max_stack:
				return i
	return -1
	
func find_best_insert_slot(item):
	var lowest_stack_item = -1
	
	for i in range(0, 24):
		if inventory[i] == null && !item.stackable:
			return i
		if inventory[i] != null && inventory[i].ID == item.ID && item.stackable:
			if inventory[i].count < item.max_stack:
				if lowest_stack_item != -1 && inventory[i].count < inventory[lowest_stack_item].count:
					lowest_stack_item = i
				if lowest_stack_item == -1:
					lowest_stack_item = i

	if lowest_stack_item != -1:
		return lowest_stack_item
	else:
		for i in range(0, 24):
			if inventory[i] == null:
				return i
		
func can_sell():
	for i in inventory:
		if i != null && i.sellable:
			return true
	return false

#total number of a certain item that the player has
func get_total_item_count(item) -> int:
	var count = 0
	
	for n in inventory:
		if n != null && n.ID == item.ID:
			count += n.count
		
	return count
	
func find_available_selling_inv_slot(item):
	var lowest_stack_item = -1
	
	for i in range(0, 24):
		if inventory[i] != null && inventory[i].ID == item.ID:
			if lowest_stack_item != -1:
				if inventory[i].count < inventory[lowest_stack_item].count:
					lowest_stack_item = i
			if lowest_stack_item == -1:
				lowest_stack_item = i
	return lowest_stack_item
		
func add_to_inv(item): # returns false if you cannot currently fit the item in your inventory

	var item_dup = item.duplicate()
	while item_dup.count > 0:

		var ind = find_best_insert_slot(item_dup)
		if ind >= 0:
			#print("index:",ind)
			if inventory[ind] != null and inventory[ind].ID == item.ID:
				#print("????")
				item_dup.count -= 1
				inventory[ind].count += 1
			else:
				var item_dup_2 = item_dup.duplicate()
				item_dup_2.count = 1
				item_dup.count -= 1
				inventory[ind] = item_dup_2
				#print(item_dup.count)
				
		else:
			return false
	return true
		
func remove_from_inv(item):
	while item.count > 0:
		var ind = find_available_selling_inv_slot(item)
		if inventory[ind] != null and inventory[ind].ID == item.ID:
			inventory[ind].count -= 1
			item.count -= 1
			if inventory[ind].count == 0:
				inventory[ind] = null
		else:
			return false
	return true

func interact(obj):
	if not actionable:
		return
	if obj is flower:
		water_or_harvest(obj)
	elif obj is NPC:
		obj.speak()
	elif obj is PlantableTile:
		plant_on(obj)
	
	pass

func water_or_harvest(obj:flower):
	if held_item() == null:
		print("[INTERACT] No held item")
		return
	if not History.has_happened("unlock_watering"):
		print("[INTERACT] Watering not unlocked")
		return
	print("[INTERACT] Held item: ", held_item(), " is Scythe: ", held_item() is Scythe)
	if held_item() is Scythe:
		print("[INTERACT] Calling harvest on ", obj)
		obj.harvest()
	elif held_item() is Watercan:
		if held_item().use():
			SignalBus.emit_signal("plant_watered", obj)
			play_directional_anim(obj, "water")
			SignalBus.emit_signal("tutorial_watered")


func plant_on(obj:PlantableTile):
	if held_item() == null:
		return
	if not History.has_happened("unlock_planting"):
		return
	if held_item() is RainbowBean and obj is SpecialPlantableTile:
		held_item().plant_at(obj)
		return
	if held_item() is Plantable and obj.can_hold_plant():
		held_item().plant_at(obj)
		SignalBus.emit_signal("tutorial_planted")
	

func play_directional_anim(obj, action:String):
	# Calculate the direction from the player to the object
			var direction = (obj.global_position - global_position).normalized()
			# Determine the animation to play based on the direction
			var animation = action + "_"
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					animated_sprite.flip_h = false
					animation += "right"
				else:
					animated_sprite.flip_h = true
					animation += "right"
			else:
				if direction.y > 0:
					animation += "down"
				else:
					animation += "up"
			actionable = false
			animated_sprite.play(animation)
			await animated_sprite.animation_finished
			actionable = true

func held_item():
	if inventory[held_item_index] != null and inventory[held_item_index].ID == 1:
		SignalBus.emit_signal("tutorial_watercan_equipped")
	return inventory[held_item_index]

func _on_interactzone_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is DropItem:
		pickup(area.get_parent().get_parent())
	pass # Replace with function body.

func on_pos_timer_timeout():
	#print("current pos: ",pos_stack[0])
	pos_stack[0] = position
	last_pos_timer.start()

func hide_ui():
	$GameCam.hide_ui()
	
func show_ui():
	$GameCam.show_ui()
