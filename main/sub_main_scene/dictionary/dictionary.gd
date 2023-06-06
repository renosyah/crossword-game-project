extends Control

@export var words :Array

@onready var label = $VBoxContainer/HBoxContainer2/Label
@onready var dictionaries = $ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/HBoxContainer/dictionaries
@onready var margin_container_3 = $ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = tr("DICTIONARY").to_upper()

func show_dictionary():
	animation_player.play("show_dictionary")
	refresh_dictionary()
	margin_container_3.visible = (dictionaries.get_child_count() > 0)

func refresh_dictionary():
	for i in dictionaries.get_children():
		dictionaries.remove_child(i)
		i.queue_free()
		
	for i in words:
		var item = preload("res://assets/ui/dictionary_item/dictionary_item.tscn").instantiate()
		item.data = i
		dictionaries.add_child(item)
