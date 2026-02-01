extends Overworld_area
@export var play_tutorial = true
@onready var dadkiller: Area2D = $dadkiller
@onready var seasonals = [$Spring_Summer, $Spring_Summer, $Fall, $Winter]
var freezing = true
func _ready() -> void:
	super()
	SignalBus.connect("spawn_seeds", spawn_seeds)
	#SignalBus.connect("context", _on_context)
	SignalBus.connect("unlock_farmhouse", _enable_dadkiller)
	seasonals[DayManager.season].show()
	SignalBus.connect("unlock_city", _toggle_freezing)
	# Auto-trigger dad dialogue when tutorial events happen
	SignalBus.connect("tutorial_pickup", _on_tutorial_pickup)
	SignalBus.connect("tutorial_planted", _on_tutorial_planted)
	SignalBus.connect("tutorial_watered", _on_tutorial_watered)
	# Skip tutorial if already completed (loading a save)
	if History.has_happened("tutorial_finished") or History.has_happened("unlock_city"):
		freezing = false
		call_deferred("_skip_tutorial_setup")
	return

func _skip_tutorial_setup():
	grow_player()
	if $y_sorted.has_node("TutDad"):
		$y_sorted/TutDad.queue_free()

func _process(delta: float) -> void:
	super(delta)
	if freezing:
		DayManager.freeze()
		

func spawn_seeds():
	var seeds = Items.get_item(2)
	seeds.count = 1
	var drop = Items.create_drop_item(seeds)
	$seedspawnpoint.add_child(drop)

func _on_context(context:Dictionary):
	if context["recipient"] == "farm":
		$AnimationPlayer.play_animation(context["animation"])
		return

func grow_player():
	PlayerData.player.scale = Vector2(1,1)
	PlayerData.player.alter_scale = Vector2(1,1)
	return 


func _on_dadkiller_body_entered(body: Node2D) -> void:
	if body is Player: 
		
		await get_tree().create_timer(1).timeout
		if $y_sorted/TutDad != null:
			$y_sorted/TutDad.queue_free()
	pass # Replace with function body.

func _enable_dadkiller():
	dadkiller.monitoring = true

func _toggle_freezing():
	freezing = false
	DayManager.unfreeze()

func _get_tut_dad():
	if $y_sorted.has_node("TutDad"):
		return $y_sorted/TutDad
	return null

func _on_tutorial_pickup():
	var dad = _get_tut_dad()
	if dad:
		await get_tree().create_timer(0.3).timeout
		dad.speak()

func _on_tutorial_planted():
	var dad = _get_tut_dad()
	if dad:
		await get_tree().create_timer(0.3).timeout
		dad.speak()

func _on_tutorial_watered():
	var dad = _get_tut_dad()
	if dad:
		await get_tree().create_timer(0.3).timeout
		dad.speak()
