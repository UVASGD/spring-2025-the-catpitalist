extends Node


@onready var drop_items = []
@onready var dropitem = preload("res://assets/scenes/drop_item.tscn")
var items = {
	1: ["res://assets/scenes/items/watercan.tscn"],
	2: ["res://assets/scenes/items/seeds.tscn"],
	3: ["res://assets/scenes/items/flower.tscn"],
	4: ["res://assets/scenes/items/cornseeds.tscn"],
	5: ["res://assets/scenes/items/corn.tscn"],
	6: ["res://assets/scenes/items/basilseeds.tscn"],
	7: ["res://assets/scenes/items/basil.tscn"],
	8: ["res://assets/scenes/items/chickensandwichseeds.tscn"],
	9: ["res://assets/scenes/items/chickensandwich.tscn"],
	10: ["res://assets/scenes/items/greenbeanseeds.tscn"],
	11: ["res://assets/scenes/items/greenbean.tscn"],
	12: ["res://assets/scenes/items/pickleseeds.tscn"],
	13: ["res://assets/scenes/items/pickle.tscn"],
	14: ["res://assets/scenes/items/blueseeds.tscn"],
	15: ["res://assets/scenes/items/blue.tscn"],
	16: ["res://assets/scenes/items/starseeds.tscn"],
	17: ["res://assets/scenes/items/star.tscn"],
	18: ["res://assets/scenes/items/wheatseeds.tscn"],
	19: ["res://assets/scenes/items/wheat.tscn"],
	20: ["res://assets/scenes/items/breadseeds.tscn"],
	21: ["res://assets/scenes/items/bread.tscn"],
	22: ["res://assets/scenes/items/alientranslator.tscn"],
	23: ["res://assets/scenes/items/loansharksuit.tscn"],
	24: ["res://assets/scenes/items/strangepiece.tscn"],
	25: ["res://assets/scenes/items/rainbowbean.tscn"],
	29: ["res://assets/scenes/items/sadpoetry.tscn"],
	31: ["res://assets/scenes/items/scythe.tscn"],
	32: [""],
	33: [""],
	34: [""],
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_items()
	pass # Replace with function body.




func load_items():
	for item in items:
		items[item].append(load(items[item][0]))

	SignalBus.emit_signal("items_ready")


func get_item(id):
	return items[id][1].instantiate() #id - 1 to account for arrays starting at 0 

func clone(item): # will only copy over the count, anything else might need a more specific function
	var pack = items[item.ID][1]
	var newitem = pack.instantiate()
	newitem.count = item.count 
	return newitem

func create_drop_item(item):
	if item:
		var newdrop = dropitem.instantiate()
		newdrop.set_item(item)
		return newdrop

func buy(cart:Dictionary):
	for item in cart:
		#print(Items.get_item(cart[item]).item_name)
		#repeat for the amount being bought
		for i in range(0, cart[item]):
			PlayerData.player.add_to_inv(Items.get_item(item))
	return
	
func sell(sellercart:Dictionary):
	for item in sellercart:
		var to_remove = Items.get_item(item)
		to_remove.count = sellercart[item]
		PlayerData.player.remove_from_inv(to_remove)
	return
