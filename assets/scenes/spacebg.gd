extends Node2D
@onready var star_timer:Timer
@onready var mat:ShaderMaterial
@onready var stars = $stars

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mat = $TextureRect.material
	star_timer = Timer.new()
	star_timer.wait_time = 2
	
	star_timer.connect("timeout", _on_star_timer_timeout)
	add_child(star_timer)
	star_timer.start(2)
	pass # Replace with function body.



var t := 0.0
func _process(delta):
	t += delta
	
	mat.set_shader_parameter("time", t)

func _on_star_timer_timeout():
	var tween = create_tween()  # <--- fresh tween each time

	var star_list = stars.get_children()
	if star_list.size() == 0:
		return

	var star = star_list[randi() % star_list.size()]
	star.modulate.a = 0.0
	star.visible = true

	tween.tween_property(star, "modulate:a", 1.0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_interval(1.0)
	tween.tween_property(star, "modulate:a", 0.0, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(star, "hide"))

	star_timer.start(2)
