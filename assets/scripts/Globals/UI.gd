extends Node

var shops = {
	"Scrappy*":"res://assets/scenes/ui/shops/breakingscraps.tscn",
	"Catnip Dealer":"res://assets/scenes/ui/shops/catdealer.tscn",
	"Garebear":"res://assets/scenes/ui/shops/Garebear.tscn",
	"Gerardo":"res://assets/scenes/ui/shops/Gerardo.tscn",
	"Trippi Troppi": "res://assets/scenes/ui/shops/tttt.tscn"
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_shops()
	pass # Replace with function body.




func load_shops():
	for shop_name in shops.keys():
		shops[shop_name] = load(shops[shop_name])
	return

func open_shop(inventory:Array, npc:NPC):
	print("opening shop")
	var packed = shops[npc.npc_name]
	var shop:Shop = packed.instantiate()
	shop.inventory = inventory
	SceneSwapper.change_scene(packed)
	return

func close_shop():
	SceneSwapper.pop()
