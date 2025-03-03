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


var cart = {} # Player's shopping cart. key value pairs where key = item ID, and value = count
var sellercart = {} # like cart, but for stuff the player is selling
var inventory = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue.text = choosing_dialogue
	Music.play(songtitle)
	DayManager.freeze()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func close():
	UI.close_shop()
	return
	

func _on_leave_pressed() -> void:
	dialogue.text = leaving_dialogue
	close()
	DayManager.unfreeze()
	pass # Replace with function body.



func _on_choose_sell_pressed() -> void:
	texture_rect.show()
	sellbuttons.show()
	invscroller.show()
	choose.hide()
	leave.hide()
	dialogue.text = sellscreen_dialogue
	mode.text = "SELL"
	pass # Replace with function body.


func _on_choose_buy_pressed() -> void:
	texture_rect.show()
	buybuttons.show()
	invscroller.show()
	choose.hide()
	leave.hide()
	dialogue.text = buyscreen_dialogue
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
	if cart.is_empty:
		return
	dialogue.text = buy_dialogue
	Items.buy(cart)
	cart = {}
	pass # Replace with function body.


func _on_sell_pressed() -> void:
	if sellercart.is_empty():
		return
	dialogue.text = sell_dialogue
	Items.sell(sellercart)
	sellercart = {}
	pass # Replace with function body.
