extends Control

signal back

@onready var label = $VBoxContainer/HBoxContainer2/Label
@onready var v_box_container = $VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = tr("PRIZE")
	
func show_prize():
	_remove_child(v_box_container)
	
func _remove_child(node :Control):
	for i in node.get_children():
		node.remove_child(i)
		i.queue_free()
		
	node.custom_minimum_size.y = 0
	
func _on_back_button_pressed():
	emit_signal("back")

