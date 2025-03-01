#class to store player data to savefile, and for other classes to globally access the player's data 
extends Node
var player:Player
var playerpacked = preload("res://assets/scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("player_ready", _on_player_ready)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

func clone_and_kill(): # removes reference to old plaeyr
	if player:
		var newplayer = clone()
		player.queue_free()
		player = newplayer
		return newplayer

func clone():
	if player:
		var newplayer:Player = playerpacked.instantiate()
		newplayer.money = player.money
		newplayer.inventory = player.inventory
		newplayer.held_item_index = player.held_item_index
		newplayer.pos_stack = player.pos_stack
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
