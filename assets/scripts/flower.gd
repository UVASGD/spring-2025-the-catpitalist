class_name flower extends Interactable
@export var growth_time: int # amount of days it takes to reach next stage 
@export var hardiness: int # amount of days this plant can go without watering 
@export var debug: bool
@onready var stages = [$seed, $sprout, $bud, $bloom, $dead]
var current_stage_index = 0
var watered = false
var days_since_growth = 0
var days_since_watered = 0
var dead = false
var bloomed = false
@onready var debugHolder: Node = $debugHolder
@onready var stagelabel: Label = $debugHolder/Control/HBoxContainer/stage
@onready var dswlabel: Label = $debugHolder/Control/HBoxContainer/dsw
@onready var dsglabel: Label = $debugHolder/Control/HBoxContainer/dsg
@onready var water_indicator: ColorRect = $debugHolder/Control/waterIndicator

@export var seed_item_id: int
@export var flower_item_id: int
@export var seeds_dropped_on_harvest: int = 0
@export var flowers_dropped_on_harvest: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SignalBus.connect("morning_growth", age)
	SignalBus.connect("plant_watered", get_watered)
	if debug:
		if debugHolder:
			debugHolder.show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if debug and debugHolder:
		stagelabel.text = "s:" + str(current_stage_index)
		dswlabel.text = "w:" + str(days_since_watered)
		dsglabel.text = "g:" + str(days_since_growth)
		if watered:
			water_indicator.color = Color(0,0,255)
		else:
			water_indicator.color = Color(255,0,0)
	pass

func age():
	if dead:
		return
	if watered:
		days_since_growth += 1
		if(days_since_growth == growth_time):
			grow()
	days_since_watered += 1
	if days_since_watered == hardiness and bloomed:
		die()
	watered = false
	return
	
func harvest():
	var to_drop = null
	# stages: 0=seed, 1=sprout, 2=bud, 3=bloom, 4=dead
	var bloom_index = stages.size() - 2  # index 3
	
	print("[HARVEST] current_stage_index=", current_stage_index, " bloom_index=", bloom_index, " dead=", dead, " bloomed=", bloomed)
	print("[HARVEST] seed_item_id=", seed_item_id, " flower_item_id=", flower_item_id)
	
	if dead or current_stage_index >= stages.size() - 1:
		# Dead plants drop nothing
		print("[HARVEST] Result: DEAD - dropping nothing")
		pass
	elif current_stage_index == bloom_index:
		# Only bloom stage drops flowers
		print("[HARVEST] Result: BLOOM - dropping flower id=", flower_item_id)
		to_drop = Items.get_item(flower_item_id)
		to_drop.count = flowers_dropped_on_harvest
		
		#drop seeds from a bloom (if applicable)
		if seeds_dropped_on_harvest:
			var seed_item = Items.get_item(seed_item_id)
			seed_item.count = seeds_dropped_on_harvest
			var seed_drop = Items.create_drop_item(seed_item)
			PlayerData.player.drop(seed_drop, true)  # from_harvest = true
	else:
		# Not fully grown (seed/sprout/bud) - just drop the seed back
		print("[HARVEST] Result: NOT GROWN - dropping seed id=", seed_item_id)
		to_drop = Items.get_item(seed_item_id)
		to_drop.count = 1
	if to_drop:
		var dropped = Items.create_drop_item(to_drop)
		PlayerData.player.drop(dropped, true)  # from_harvest = true
	#delete self
	self.queue_free()
	
func get_watered(body):
	if body == self and not watered and not dead:
		watered = true
		days_since_watered = 0
		pass
	else:
		pass

func grow():
	if not bloomed:
		stages[current_stage_index].hide()
		current_stage_index += 1
		stages[current_stage_index].show()
		days_since_growth = 0
		bloomed = (current_stage_index == stages.size() - 2)
		print(bloomed)
	pass

func die():
	dead = true
	stages[current_stage_index].hide()
	stages[stages.size() -1].show() # should always be dead sprite 
	pass
