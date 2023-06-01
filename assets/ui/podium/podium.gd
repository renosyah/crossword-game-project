extends MarginContainer

const podium_item_scene = preload("res://assets/ui/podium/podium_item/podium_item.tscn")

@export var top_3 :Array

@onready var position_1 = $HBoxContainer/CenterContainer/position_1
@onready var position_2 = $HBoxContainer/CenterContainer2/position_2
@onready var position_3 = $HBoxContainer/CenterContainer3/position_3

@onready var h_box_container = $HBoxContainer
@onready var animation_player = $AnimationPlayer

func show_rank():
	_remove_child(position_1)
	_remove_child(position_2)
	_remove_child(position_3)
	
	if top_3.is_empty() or top_3.size() < 3:
		return
		
	var pos :int = 0
	for i in [position_1, position_2, position_3]:
		var data = top_3[pos]
		var podium_item = podium_item_scene.instantiate()
		podium_item.number = pos + 1
		podium_item.level = data["level"]
		podium_item.player = data["player"]
		i.add_child(podium_item)
		pos += 1

func _remove_child(node :Node):
	for i in node.get_children():
		node.remove_child(i)
		i.queue_free()
	
func hide_podium():
	animation_player.play("show_nomal_list")

func show_podium():
	animation_player.play_backwards("show_nomal_list")
	














