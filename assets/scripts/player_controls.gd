extends Node

@onready var player: CharacterBody2D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connect("inv_opened", _on_open_inv)
	SignalBus.connect("inv_closed", _on_close_inv)
	SignalBus.connect("dialogue_finished", _on_dialogue_finish)
	SignalBus.connect("new_dialogue", _on_dialogue)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player.actionable:
		return
	#var velocity: Vector2 = Vector2.ZERO
	# Check for input to set the velocity
	if Input.is_action_pressed("up"):
		player.animated_sprite.flip_h = false
		#velocity.y -= 1
		player.animated_sprite.play("walk_up")
	elif Input.is_action_pressed("down"):
		player.animated_sprite.flip_h = false
		#velocity.y += 1
		player.animated_sprite.play("walk_down")
	elif Input.is_action_pressed("left"):
		#velocity.x -= 1
		player.animated_sprite.flip_h = true
		player.animated_sprite.play("walk_right")
	elif Input.is_action_pressed("right"):
		player.animated_sprite.flip_h = false
		#velocity.x += 1
		player.animated_sprite.play("walk_right")
	elif Input.is_action_pressed("slot0"):
		player.held_item_index = 0
	elif Input.is_action_pressed("slot1"):
		player.held_item_index = 1
	elif Input.is_action_pressed("slot2"):
		player.held_item_index = 2
	elif Input.is_action_pressed("slot3"):
		player.held_item_index = 3
	elif Input.is_action_pressed("slot4"):
		player.held_item_index = 4
	elif Input.is_action_pressed("slot5"):
		player.held_item_index = 5
	# If no input is detected, stop the animation
	if player.velocity == Vector2.ZERO:
		player.animated_sprite.stop()
		player.animated_sprite.frame = 0  # Reset the animation to the first frame
	# Normalize the velocity to prevent faster diagonal movement
	#if velocity.length() > 0:
		#velocity = velocity.normalized() * player.speed

	# Move the character
	#player.velocity = velocity
	return

func _on_dialogue(_dialogue):
	player.actionable = false

func _on_dialogue_finish():
	player.actionable = true

func _on_open_inv():
	player.actionable = false
	return

func _on_close_inv():
	player.actionable = true
	return
