class_name Shop extends CanvasLayer

@export var npc_name:String
@export var songtitle: String
@onready var bg: TextureRect = $BG
@onready var portrait: TextureRect = $Portrait
@onready var cardboard: TextureRect = $Cardboard
@onready var mode: Label = $TextureRect/mode
@onready var texture_rect: TextureRect = $TextureRect
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var invscroller: ScrollContainer = $invscroller
@onready var inv: VBoxContainer = $invscroller/inv
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var dbox: TextureRect = $HBoxContainer/dbox
@onready var dialogue: Label = $HBoxContainer/dbox/dialogue
@onready var sellbuttons: VBoxContainer = $HBoxContainer/sellbuttons
@onready var buybuttons: VBoxContainer = $HBoxContainer/buybuttons
@onready var choose: HBoxContainer = $choose
@onready var leave: TextureButton = $HBoxContainer/leave

@export var buy_dialogue: String
@export var sell_dialogue: String
@export var buyscreen_dialogue: String
@export var sellscreen_dialogue: String
@export var choosing_dialogue: String
@export var leaving_dialogue: String

@export var shop_items_sold: Array[int]

var cart = {} # Player's shopping cart. key value pairs where key = item ID, and value = count
var sellercart = {} # like cart, but for stuff the player is selling
var inventory = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.text = choosing_dialogue
	Music.play(songtitle)
	DayManager.freeze()
	
	SignalBus.connect("shop_price_change", _on_price_change)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func close():
	UI.close_shop()
	return
	
func get_buyscreen_dialogue() -> String:
	var part1 = buyscreen_dialogue.substr(0, buyscreen_dialogue.find("*"))
	var part2 = buyscreen_dialogue.substr(buyscreen_dialogue.find("*") + 1)
	
	return str(part1, get_cart_cost(), part2)
	
func get_sellscreen_dialogue() -> String:
	var part1 = sellscreen_dialogue.substr(0, sellscreen_dialogue.find("*"))
	var part2 = sellscreen_dialogue.substr(sellscreen_dialogue.find("*") + 1)
	
	return str(part1, get_sellercart_cost(), part2)

func _on_leave_pressed() -> void:
	dialogue.text = leaving_dialogue
	await get_tree().create_timer(1).timeout
	close()
	DayManager.unfreeze()
	pass # Replace with function body.

func _on_price_change():
	if dialogue.text.substr(0,4) == buyscreen_dialogue.substr(0,4):
		dialogue.text = get_buyscreen_dialogue()
	elif dialogue.text.substr(0,4) == sellscreen_dialogue.substr(0,4):
		dialogue.text = get_sellscreen_dialogue()

func _on_choose_sell_pressed() -> void:
	sellercart = {}
	if PlayerData.player.can_sell():
		var player_items = []
		for n in inv.get_children():
			inv.remove_child(n)
			n.queue_free()
		for n in PlayerData.player.inventory:
			if n is Item && n.sellable && !player_items.has(n.ID):
				player_items.append(n.ID)
				var x = preload("res://shopitemrow.tscn").instantiate()
				x.item_id = n.ID
				x.is_buy_item = false
				inv.add_child(x)
		texture_rect.show()
		sellbuttons.show()
		invscroller.show()
		choose.hide()
		leave.hide()
		dialogue.text = get_sellscreen_dialogue()
		mode.text = "SELL"
	else:
		dialogue.text = "You have nothing to sell."
		
		await get_tree().create_timer(1.5).timeout
		if dialogue.text == "You have nothing to sell.":
			dialogue.text = choosing_dialogue
	pass # Replace with function body.


func _on_choose_buy_pressed() -> void:
	cart = {}
	for n in inv.get_children():
		inv.remove_child(n)
		n.queue_free()
	for n in shop_items_sold:
		var x = preload("res://shopitemrow.tscn").instantiate()
		x.item_id = n
		x.is_buy_item = true
		inv.add_child(x)
		#x.item_id = n
		#x.is_buy_item = true
	texture_rect.show()
	buybuttons.show()
	invscroller.show()
	choose.hide()
	leave.hide()
	dialogue.text = get_buyscreen_dialogue()
	mode.text = "BUY"
	pass # Replace with function body.


func _on_back_pressed() -> void:
	texture_rect.hide()
	sellbuttons.hide()
	invscroller.hide()
	buybuttons.hide()
	choose.show()
	leave.show()
	dialogue.text = choosing_dialogue
	pass # Replace with function body.


func _on_buy_pressed() -> void:
	PlayerData.player.money = 100
	if cart.is_empty():
		return
	var buy_check = can_buy()
	if buy_check.has(true):
		dialogue.text = buy_check[true]
		Items.buy(cart)
		cart = {}
	elif buy_check.has(false):
		dialogue.text = buy_check[false]
	await get_tree().create_timer(1.5).timeout
	if (buy_check.has(true) && dialogue.text == buy_check[true]) || (buy_check.has(false) && dialogue.text == buy_check[false]):
		dialogue.text = get_buyscreen_dialogue()
	pass # Replace with function body.


func _on_sell_pressed() -> void:
	if sellercart.is_empty():
		return
	dialogue.text = sell_dialogue
	Items.sell(sellercart)
	sellercart = {}
	
	var player_items = []
	for n in inv.get_children():
		inv.remove_child(n)
		n.queue_free()
	for n in PlayerData.player.inventory:
		if n is Item && n.sellable && !player_items.has(n.ID):
			player_items.append(n.ID)
			var x = preload("res://shopitemrow.tscn").instantiate()
			x.item_id = n.ID
			x.is_buy_item = false
			inv.add_child(x)
	
	await get_tree().create_timer(1.5).timeout
	if dialogue.text == sell_dialogue:
		dialogue.text = get_sellscreen_dialogue()
	if !PlayerData.player.can_sell():
		_on_back_pressed()
	pass # Replace with function body.
	
# checks if the player can buy what's in the cart
# returns a dictionary of true/false and an error message if applicable
func can_buy() -> Dictionary:
	if get_cart_cost() > PlayerData.player.money:
		return {false: "Yer too broke. Put some things away!"}
	elif !can_fit_items():
		return {false: "You can't hold all that!"}
	return {true: buy_dialogue}
	
func can_fit_items() -> bool:
	return true
	
func get_cart_cost() -> float:
	var cost = 0.00
	
	for item in cart:
		#add price * quantity
		cost += Items.get_item(item).buy_price * cart[item]
	
	return cost
	
func get_sellercart_cost() -> float:
	return 0.00
