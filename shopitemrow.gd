extends HBoxContainer

@export var item_id: int
@export var is_buy_item: bool

@onready var label: Label = $Label
@onready var spriteholder: TextureRect = $spriteholder
@onready var itemname: Label = $itemname
@onready var decreasebutton: TextureButton = $decreasebutton
@onready var countholder: TextureRect = $countholder
@onready var countlabel: Label = $countholder/countlabel
@onready var increasebutton: TextureButton = $increasebutton

#may need a more stable way to reference the cart
#@onready var cart = owner.cart
var cart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shop_item = Items.get_item(item_id)
	if is_buy_item:
		label.text = str("$",shop_item.buy_price)
	else:
		label.text = str("$",shop_item.sell_price)
	itemname.text = shop_item.item_name
	spriteholder.texture = load(shop_item.sprite_path)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_buy_item:
		if owner:
			cart = owner.cart
		else:
			cart = get_parent().get_parent().get_parent().cart
	else:
		if owner:
			cart = owner.cart
		else:
			cart = get_parent().get_parent().get_parent().sellercart
	if cart.has(item_id):
		countlabel.text = str(cart[item_id])
	else:
		countlabel.text = "0"
			
	pass

func additem():
	# add/increment the item to cart, but first check if the player could reasonably buy it
	# check if they can afford their whole cart plus this new item
	# check if this item would overflow their inventory
	# edge case, when purchasing stacks of things, player could already have a few, so be careful with that
	
	#countlabel.text = str(int(countlabel.text)+1)
	if cart.has(item_id):
		cart[item_id] += 1
	else:
		cart[item_id] = 1
	#owner.buy_dialogue = str("That'll run you $", owner.get_cart_cost(), " clams.")
	#owner.dialogue.text = owner.buy_dialogue
	print(cart)
	return

func removeitem():
	#countlabel.text = str(int(countlabel.text)-1)
	if cart.has(item_id):
		if cart[item_id] > 1:
			cart[item_id] -= 1
		elif cart[item_id] == 1:
			cart.erase(item_id)
	#owner.buy_dialogue = str("That'll run you $", owner.get_cart_cost(), " clams.")
	#owner.dialogue.text = owner.buy_dialogue
	print(cart)
	return
