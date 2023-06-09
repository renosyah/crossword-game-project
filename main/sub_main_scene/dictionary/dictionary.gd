extends Control

signal back

@export var words :Array

@onready var label = $VBoxContainer/HBoxContainer2/Label
@onready var dictionaries = $ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/HBoxContainer/dictionaries
@onready var margin_container_3 = $ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3
@onready var animation_player = $AnimationPlayer
@onready var empty_list = $Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = tr("DICTIONARY").to_upper()
	empty_list.text = tr("EMPTY_LIST")

func show_dictionary():
	margin_container_3.visible = false
	empty_list.visible = false
	
	for i in dictionaries.get_children():
		dictionaries.remove_child(i)
		i.queue_free()
		
	await get_tree().process_frame
	
	var is_empty :bool = words.is_empty()
	margin_container_3.visible = not is_empty
	empty_list.visible = is_empty
	
	animation_player.play("RESET")
	await animation_player.animation_finished
	
	_show_words()
	
	animation_player.play("show_dictionary")
	
func _show_words():
	for i in words:
		var item = preload("res://assets/ui/dictionary_item/dictionary_item.tscn").instantiate()
		item.data = i
		dictionaries.add_child(item)
	
func _on_back_button_pressed():
	emit_signal("back")
