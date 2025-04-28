class_name Beanstalk extends "res://assets/scripts/flower.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func age():
	if watered:
		days_since_growth += 1
		if(days_since_growth == growth_time):
			grow()
	days_since_watered += 1
	watered = false
	return
	
func harvest():
	return
	
func grow():
	SignalBus.emit_signal("beanstalk_grew")
	History.mark("beanstalk_grew")
