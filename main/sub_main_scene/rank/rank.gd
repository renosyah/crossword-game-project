extends VBoxContainer

const rank_item_scene = preload("res://assets/ui/rank_item/rank_item.tscn")

@onready var ranks = $ScrollContainer/HBoxContainer/MarginContainer3/VBoxContainer/ranks

func show_ranks():
	if not ranks.get_children().is_empty():
		return
		
	for i in 10:
		if i < 3:
			continue
			
		var rank_item = rank_item_scene.instantiate()
		rank_item.number = i + 1
		rank_item.level = 69
		rank_item.player = Global.player
		ranks.add_child(rank_item)
