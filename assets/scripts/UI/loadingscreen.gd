extends CanvasLayer

signal loading_complete

# References to nodes in your scene
@onready var progress_bar = $ColorRect/MarginContainer/VBoxContainer/TextureProgressBar

@onready var animation_player = $AnimationPlayer

var target_scene = ""
var progress = []
var ended = false
func _ready():
	progress_bar.value = 0
	animation_player.play("fade_in")

func end():
	animation_player.play("fade_out")
	await animation_player.animation_finished
	ended = true
	return

func update(prog:Array):
	progress_bar.value = prog[0] * 100
	if prog[0] == 1 and not ended:
		await end()
		return

func fake():
	animation_player.play("fake")
	await animation_player.animation_finished
	return
