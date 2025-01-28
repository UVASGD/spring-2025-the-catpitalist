class_name Tool extends Item
@export var charges:int
@export var max_charges:int


func use():
	charges -= 1
	if charges == 0:
		print("out of charges. deleting myself")
		self.queue_free()
	return true # returns true if successfully used

#eventually add functionality for a health bar here 
