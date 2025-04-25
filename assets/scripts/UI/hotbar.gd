extends CanvasLayer
@onready var slots: HBoxContainer = $Control/VBoxContainer/slots

var active_index = 0
var green = Color(0.031,0.5,0.0376)
var grey = Color(0.5, 0.5, 0.5)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("new_dialogue", _on_new_dialogue)
	SignalBus.connect("dialogue_finished", _on_dialogue_finish)
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("slot0"):
		flash_label()
		active_index = 0
	if event.is_action_pressed("slot1"):
		flash_label()
		active_index = 1
	if event.is_action_pressed("slot2"):
		flash_label()
		active_index = 2
	if event.is_action_pressed("slot3"):
		flash_label()
		active_index = 3
	if event.is_action_pressed("slot4"):
		flash_label()
		active_index = 4
	if event.is_action_pressed("slot5"):
		flash_label()
		active_index = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for slot in slots.get_children():
		sync(slot)
	pass

func flash_label():
	print("flash")
	#if $AnimationPlayer.is_playing:
		#print("waiting")
		#await $AnimationPlayer.animation_finished
	print("playing")
	$AnimationPlayer.play("flash")
	
func sync(slot:TextureRect):
	var item_index = slot.get_index()
	var item = PlayerData.inventory(item_index)
	slot.get_child(2).hide()
	
	# Create local copies of needed data
	var item_data = null
	var i = 0
	while(i<100):
		if item:
			if item:
				if item != null:
					item_data = {
						"sprite_path": item.sprite_path,
						"stackable": item.stackable,
						"count": item.count,
						"item_name": item.item_name
					}
					break
		i=i+1
	
	# Now use item_data instead of item
	if item_data:
		var image = load(item_data.sprite_path)
		var texture = ImageTexture.create_from_image(image)
		slot.get_child(0).texture = texture
		
		var text
		if item_data.stackable:
			if item_data.count < 10:
				text = "0" + str(item_data.count)
			else:
				text = str(item_data.count)
			slot.get_child(1).text = text
	else:
		slot.get_child(0).texture = null
		slot.get_child(1).text = ""
		
	if slot.get_index() == active_index:
		if item_data:
			$Control/VBoxContainer/Label.text = item_data.item_name
		slot.get_child(2).show()
	else:
		slot.get_child(2).hide()

func _on_new_dialogue(_dialogue):
	self.hide()

func _on_dialogue_finish():
	self.show()
