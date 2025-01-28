class_name Item extends Node2D
@export var ID:int
@export var item_name : String
@export var stackable : bool
@export var max_stack : int
@export var count : int
@export var description : String
@export var sellable: bool
@export var sell_price: int
@export var buy_price: int
@export var sprite_path: String
@onready var sprite = $Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func decrease_count():
	if count == 1:
		self.queue_free()
	else:
		count -= 1
