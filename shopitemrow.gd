extends HBoxContainer
@onready var label: Label = $Label
@onready var spriteholder: TextureRect = $spriteholder
@onready var itemname: Label = $itemname
@onready var decreasebutton: TextureButton = $decreasebutton
@onready var countholder: TextureRect = $countholder
@onready var countlabel: Label = $countholder/countlabel
@onready var increasebutton: TextureButton = $increasebutton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func additem():
	# add/increment the item to cart, but first check if the player could reasonably buy it
	# check if they can afford their whole cart plus this new item
	# check if this item would overflow their inventory
	# edge case, when purchasing stacks of things, player could already have a few, so be careful with that
	countlabel.text = str(int(countlabel.text)+1)
	return

func removeitem():
	countlabel.text = str(int(countlabel.text)-1)
	return
