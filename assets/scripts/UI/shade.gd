extends ColorRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = Color(0.2, 0.1, 0.0, 0.0) # deep blue with 0 alpha initially

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_night_overlay()

func update_night_overlay():


	var t = int(DayManager.time) % int(DayManager.MIDNIGHT_TIME)

	var dusk_start = DayManager.DUSK_START_TIME
	var midnight = DayManager.MIDNIGHT_TIME
	var dawn_end = DayManager.DAWN_END_TIME

	var new_alpha = 0.0

	if t >= dusk_start and t <= midnight:
		# Dusk to Midnight: Fade in
		var dusk_duration = midnight - dusk_start
		new_alpha = float(float(t - dusk_start) / float(dusk_duration))
	elif t >= 0 and t <= dawn_end:
		# Midnight to Dawn: Fade out
		var dawn_duration = dawn_end
		new_alpha = 1.0 - (t / dawn_duration)
	else:
		# Daytime: fully invisible
		new_alpha = 0.0

	# Clamp alpha between 0-1 to be safe
	new_alpha = clamp(new_alpha, 0.0, 1.0)

	# Update the modulation color alpha
	var c = color
	c.a = new_alpha
	color = c
