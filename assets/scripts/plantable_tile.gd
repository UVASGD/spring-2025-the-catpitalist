class_name PlantableTile extends Interactable
var held_plant:flower = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_shading()
	pass

func plant(obj:flower):
	held_plant = obj
	add_child(obj)
	$hitbox.input_pickable = false

func can_hold_plant():
	return held_plant == null

func update_shading():
	if held_plant:
		if is_instance_valid(held_plant):
			$shading.visible = held_plant.watered
		else:
			held_plant = null
			$hitbox.input_pickable = true

func _restore_plant(plant_obj: flower, stage: int):
	held_plant = plant_obj
	add_child(plant_obj)
	$hitbox.input_pickable = false
	# Update visual to match saved stage
	for i in range(plant_obj.stages.size()):
		plant_obj.stages[i].hide()
	if stage < plant_obj.stages.size():
		plant_obj.stages[stage].show()
