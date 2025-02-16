class_name Plantable extends Item
@export var path_to_flower:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func plant_at(obj:PlantableTile):
	obj.plant(get_plant())
	decrease_count()

func get_plant():
	return load(path_to_flower).instantiate()
