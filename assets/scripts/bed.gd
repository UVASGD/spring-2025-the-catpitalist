extends Interactable
class_name Bed

func interact():
	super()
	#if already past midnight, don't want to increment twice
	if DayManager.time > DayManager.DAWN_END_TIME: # before midnight
		DayManager.day_num += 1
	DayManager.sleep(false)
