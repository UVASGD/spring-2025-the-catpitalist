extends Interactable
class_name Bed

func interact():
	super()
	DayManager.end_day()
