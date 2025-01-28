extends CharacterBody2D

@export var speed := 200
@onready var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"

var money = 0
var actionable = true
var inventory = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
var inv_showing = false
var inv_cooldown = false
var can_pickup = true
var held_item_index = 0
func _ready() -> void:
	SignalBus.connect("interact", interact)
	#SignalBus.connect("items_ready", _on_items_ready)
	inventory[0] = Items.get_item(1) # debug watercan 
	inventory[1] = Items.get_item(1) #stack test
	inventory[2] = Items.get_item(2) # seeds test
	SignalBus.emit_signal("player_ready", self)
	

func _physics_process(delta):
	if actionable:
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction * speed
		move_and_slide()

func _on_items_ready():
	print("player recieved items ready")
	inventory[0] = Items.get_item(1) # debug watercan 
	SignalBus.emit_signal("player_ready", self)




func drop(item):
	if item:
		can_pickup = false
		get_tree().root.add_child(item)
		print(position)
		print(item.global_position)
		item.global_position = position
		print(item.global_position)
		await get_tree().create_timer(5).timeout
		can_pickup = true

func pickup(item:DropItem):
	if can_pickup:
		add_to_inv(item.give())
		
func find_available_inv_slot(item):
	for i in range(0,24):
		if inventory[i] == null:
			return i
		elif inventory[i].ID == item.ID:
			if inventory[i].stackable and inventory[i].count + item.count <= item.max_stack:
				return i
	return -1
		
func add_to_inv(item): # returns false if you cannot currently fit the item in your inventory
	var ind = find_available_inv_slot(item)
	if ind >= 0:
		if inventory[ind] and inventory[ind].ID == item.ID:
			inventory[ind].count += item.count
		else:
			inventory[ind] = item
		return true
	else:
		return false
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
	if held_item() is Plantable and obj.can_hold_plant():
		held_item().plant_at(obj)
	
func water(obj):
	if held_item() is Watercan:
		if held_item().use():
			SignalBus.emit_signal("plant_watered", obj)
			play_directional_anim(obj, "water")

func play_directional_anim(obj, action:String):
	# Calculate the direction from the player to the object
			var direction = (obj.global_position - global_position).normalized()
			# Determine the animation to play based on the direction
			var animation = action + "_"
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					animation += "right"
				else:
					animation += "left"
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
	return inventory[held_item_index]


func _on_interactzone_area_entered(area: Area2D) -> void:
	if area.get_parent() is DropItem:
		pickup(area.get_parent())
	pass # Replace with function body.
