class_name Player extends CharacterBody2D

@export var speed := 200
@export var alter_scale:Vector2 = Vector2(1,1)
@onready var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var money = 100
var actionable = false
var inventory = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
var inv_showing = false
var inv_cooldown = false
var can_pickup = true
var held_item_index = 0
var last_pos_timer
var pos_stack = []
func _ready() -> void:
	animated_sprite.scale = alter_scale
	flash_actionable()
	SignalBus.connect("interact", interact)
	#SignalBus.connect("items_ready", _on_items_ready)
	inventory[8] = Items.get_item(1) # debug watercan 
	#inventory[1] = Items.get_item(1) #stack test
	#inventory[2] = Items.get_item(2) # seeds test
	SignalBus.emit_signal("player_ready", self)
	last_pos_timer = Timer.new()
	last_pos_timer.wait_time = 0.1
	last_pos_timer.connect("timeout", on_pos_timer_timeout)
	add_child(last_pos_timer)
	last_pos_timer.start()
	pos_stack.push_front(position)
	flash_collision()
	
	
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
func _physics_process(delta):
	if actionable:
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction * speed
		move_and_slide()

func _on_items_ready():
	print("player recieved items ready")
	inventory[0] = Items.get_item(1) # debug watercan 
	SignalBus.emit_signal("player_ready", self)

func restore_pos():
	pos_stack.pop_front()
	position = pos_stack.pop_front() # call twice because push happens twice per cloning


func drop(item):
	if item != null:
		if not item is DropItem and item.ID == 1:
			SignalBus.emit_signal("tutorial_dropped")
		can_pickup = false
		get_tree().root.add_child(item)
		print(position)
		print(item.global_position)
		item.global_position = position
		print(item.global_position)
		await get_tree().create_timer(5).timeout
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
	print(lowest_stack_item)
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
	print(item.count)
	var item_dup = item.duplicate()
	while item_dup.count > 0:
		print("iterating")
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

func interact(obj):
	if not actionable:
		return
	if obj is flower:
		water(obj)
	elif obj is NPC:
		obj.speak()
	elif obj is PlantableTile:
		plant_on(obj)
	pass

func plant_on(obj:PlantableTile):
	if held_item() == null:
		return
	if held_item() is Plantable and obj.can_hold_plant():
		held_item().plant_at(obj)
		SignalBus.emit_signal("tutorial_planted")
	
func water(obj):
	if held_item() != null and held_item() is Watercan:
		if held_item().use():
			SignalBus.emit_signal("plant_watered", obj)
			play_directional_anim(obj, "water")
			SignalBus.emit_signal("tutorial_watered")

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
	if area.get_parent() is DropItem:
		pickup(area.get_parent())
	pass # Replace with function body.

func on_pos_timer_timeout():
	#print("current pos: ",pos_stack[0])
	pos_stack[0] = position
	last_pos_timer.start()
