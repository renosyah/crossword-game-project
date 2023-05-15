extends MarginContainer

const score_item = preload("res://menu/score/item/score_item.tscn")

@onready var v_box_container = $SafeArea/VBoxContainer/ScrollContainer/VBoxContainer

func display_score(scores :Array):
	for i in v_box_container.get_children():
		v_box_container.remove_child(i)
		i.queue_free()
		
	var number = 1
	for i in scores:
		var item = score_item.instantiate()
		item.number = number
		item.data = i
		v_box_container.add_child(item)
		number +=1
		
func _on_back_pressed():
	visible = false
