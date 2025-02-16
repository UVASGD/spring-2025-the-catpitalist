extends Node2D
var is_hovered = false
@export var index:int
@export var is_overflow:bool

@onready var sprite = $Sprite2D
var cached_sprite_path = null
var selected = false
var hovercolor = Color(0.53,0.53,0.53,0.5)
var defaultcolor = Color(0.33,0.33,0.33,0.4)
func _ready() -> void:
	print(index)
	print(PlayerData.inventory(index))
	if is_overflow:
		hide()
	pass # Replace with function body.

func _process(_delta: float) -> void:
	update_display()

func remove_item():
	if item:
		PlayerData.remove_inv(index)


func add_stack(other):
	item().count += other.item().count
	PlayerData.remove_inv(other.index)


func split_stack():
	@warning_ignore("shadowed_variable")
	var item = item()
	if item and item.stackable and item.count > 1:
		var new_item = Items.clone(item)
		
		new_item.count = item.count - floor(item.count /2.0)
		item.count = item.count - ceil(item.count/2.0)

		PlayerData.add_overflow(new_item)

func update_display():
	if not is_overflow:
		if is_hovered:
			$ColorRect.color = hovercolor
		else:
			$ColorRect.color = defaultcolor
		if selected:
			$SelectedBorder.show()
		else:
			$SelectedBorder.hide()
		if item() == null:
			$displaycount.text = ""
			sprite.texture = null
			return
		elif item().stackable:
			$displaycount.text = str(item().count)
		@warning_ignore("shadowed_variable")
		var item = item()
		
		if item.sprite_path != cached_sprite_path:
			var image = load(item.sprite_path)
			var texture = ImageTexture.create_from_image(image)
			sprite.texture = texture
		
	return
	
func item():
	return PlayerData.inventory(index)

func drop():
	PlayerData.drop(index)

func _on_clickbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		SignalBus.emit_signal("invslot_clicked", self)


func _on_clickbox_mouse_entered() -> void:
	SignalBus.emit_signal("invslot_hovered", self)
	pass # Replace with function body.

func _on_clickbox_mouse_exited() -> void:
	SignalBus.emit_signal("invslot_unhovered", self)
	pass # Replace with function body.
