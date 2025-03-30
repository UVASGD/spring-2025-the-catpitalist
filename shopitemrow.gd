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

var cart
var shop_item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_item = Items.get_item(item_id)
	if is_buy_item:
		label.text = str("$",shop_item.buy_price)
	else:
		label.text = str("$",shop_item.sell_price)
	itemname.text = shop_item.item_name
	if is_buy_item && shop_item.count > 1:
		itemname.text += str(" (x", shop_item.count, ")")
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
			cart = owner.sellercart
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
	var addability = can_add_item()
	
	if !is_buy_item || addability == "good":
		if cart.has(item_id):
			#print(PlayerData.player.get_total_item_count(shop_item))
			if is_buy_item || (!is_buy_item && cart[item_id] < PlayerData.player.get_total_item_count(shop_item)):
				cart[item_id] += 1
		else:
			cart[item_id] = 1
		SignalBus.emit("shop_price_change")
	elif is_buy_item:
		SignalBus.emit(addability)
	
	#owner.buy_dialogue = str("That'll run you $", owner.get_cart_cost(), " clams.")
	#owner.dialogue.text = owner.buy_dialogue

	return
	
func can_add_item():
	var cart2 = cart.duplicate()
	if cart2.has(item_id):
		cart2[item_id] += 1
	else:
		cart2[item_id] = 1
	
	var empty_slots_amount = PlayerData.player.inventory.filter(func(slot): return slot == null).size()
	#print(empty_slots_amount)
	var potential_slots_amount = 0
	for i in cart2:
		if !Items.get_item(i).stackable:
			potential_slots_amount += cart2[i]
		else:
			#print(ceil(Items.get_item(i).count * cart2[i] * 1.00 / Items.get_item(i).max_stack))
			potential_slots_amount += ceil(Items.get_item(i).count * cart2[i] * 1.00 / Items.get_item(i).max_stack)
	#print(get_parent().get_parent().get_parent().get_cart_cost() + shop_item.buy_price)
	if PlayerData.player.money >= get_parent().get_parent().get_parent().get_cart_cost() + shop_item.buy_price:
		if potential_slots_amount < empty_slots_amount:
			return "good"
		else:
			for i in cart2:
				if Items.get_item(i).stackable:
					var this_item_slots_amount = PlayerData.player.inventory.filter(func(slot): return slot != null && slot.ID == i).size()
					var total_this_item = 0
					print(this_item_slots_amount, " ", cart2[i], " ")
					print(PlayerData.player.get_total_item_count(Items.get_item(i)))
					
					if cart2[i] * Items.get_item(i).count + PlayerData.player.get_total_item_count(Items.get_item(i)) > this_item_slots_amount * Items.get_item(i).max_stack:
						return "cant_hold_item"
				else:
					return "cant_hold_item"
		return "good"
	else:
		return "cant_afford_item"
	return "cant_hold_item"

func removeitem():
	#countlabel.text = str(int(countlabel.text)-1)
	if cart.has(item_id):
		if cart[item_id] > 1:
			cart[item_id] -= 1
		elif cart[item_id] == 1:
			cart.erase(item_id)
	SignalBus.emit("shop_price_change")
	#owner.buy_dialogue = str("That'll run you $", owner.get_cart_cost(), " clams.")
	#owner.dialogue.text = owner.buy_dialogue
	print(cart)
	return
