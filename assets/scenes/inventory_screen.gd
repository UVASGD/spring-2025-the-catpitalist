extends Node2D
var current_hovered = null
var last_hovered = null
var dragging = false
var selected_slot = null
@onready var overflow_slot = $slots/overflow

func _ready() -> void:
	SignalBus.connect("invslot_clicked", _on_click)
	SignalBus.connect("invslot_hovered", _on_hover)
	SignalBus.connect("invslot_unhovered", _on_unhover)
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		dragging = true
		selected_slot = current_hovered
		if overflow_slot.item():
			swap(overflow_slot, current_hovered)
		print("dragging")
	if event.is_action_released("leftclick"):
		dragging = false
		if selected_slot:
			if current_hovered:
				swap(selected_slot, current_hovered)
			else:
				drop(selected_slot)
			selected_slot.selected = false
		print("dragging false")
	if event.is_action_pressed("split_item"):
		if selected_slot:
			split(selected_slot)
	return
	
func _process(_delta: float) -> void:
	if selected_slot:
		$debug/VBoxContainer/selected.text = "selected index: " + str(selected_slot.index)
	else:
		$debug/VBoxContainer/selected.text = "selected index: None " 
	pass

func _on_click(slot):
	if selected_slot:
		selected_slot.selected = false
	selected_slot = slot
	selected_slot.selected = true
	return

func _on_hover(slot):
	current_hovered = slot
	slot.is_hovered = true
	print("hovered", slot.index)
	return

func _on_unhover(slot):
	slot.is_hovered = false
	if current_hovered:
		last_hovered = current_hovered
	current_hovered = null
	print("last hovered", last_hovered.index)
	return

func swap(current, other):
	if current == other or other == null:
		return
	var selected_item = current.item()
	var other_item = other.item()
	if other_item and selected_item.ID == other_item.ID:
		if selected_item.stackable and (selected_item.count + other_item.count <= selected_item.max_stack):
			other.add_stack(current)
			return
	PlayerData.swap_inv(other.index, current.index)

func drop(slot):
	print("dropped item")
	slot.drop()
	
	return

func split(slot):
	slot.split_stack()
