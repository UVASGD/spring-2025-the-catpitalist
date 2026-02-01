#class to store player data to savefile, and for other classes to globally access the player's data 
extends Node
var player:Player
var playerpacked = preload("res://assets/scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("player_ready", _on_player_ready)
	pass # Replace with function body.


	
func get_money_conversion(amount: int) -> String:
	if amount < 1000:
		return str(amount)
	elif amount < 1000000:
		return str((amount / 100) / 10.0) + "K"
	elif amount < 1000000000:
		return str((amount / 100000) / 10.0) + "M"
	elif amount < 1000000000000:
		return str((amount / 100000000) / 10.0) + "B"
	else:
		return "MUCHO"

func clone_and_kill(): # removes reference to old plaeyr
	if player:
		var newplayer = clone()
		player.queue_free()
		player = newplayer
		return newplayer
	else:
		player = playerpacked.instantiate()
		return player

func clone():
	if player:
		var newplayer:Player = playerpacked.instantiate()
		newplayer.is_clone = true  # Prevent tutorial watercan from being added
		newplayer.money = player.money
		newplayer.total_money_made = player.total_money_made
		newplayer.inventory = player.inventory
		newplayer.held_item_index = player.held_item_index
		newplayer.pos_stack = player.pos_stack
		newplayer.alter_scale = player.alter_scale
		newplayer.scale = player.alter_scale  # Also copy actual scale
		return newplayer

func drop(index):
	var item = player.inventory[index]
	var dropped = Items.create_drop_item(item)
	player.inventory[index] = null
	player.drop(dropped)
	
func get_current_money():
	if player:
		return player.money
	else:
		return null
		
func _on_player_ready(obj):
	player = obj
	SignalBus.emit("playerdata_ready")

func inventory(index):
	if(player):
		return player.inventory[index]

func swap_inv(first, second):
	var temp1 = player.inventory[first]
	var temp2 = player.inventory[second]
	player.inventory[first] = temp2
	player.inventory[second] = temp1

func remove_inv(index):
	player.inventory[index] = null

func add_overflow(item):
	player.inventory[24] = item

func get_active_item():
	return player.held_item()
