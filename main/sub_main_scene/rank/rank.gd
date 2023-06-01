extends VBoxContainer

const rank_item_scene = preload("res://assets/ui/rank_item/rank_item.tscn")

@onready var top_rank = $ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/top_rank_container/top_rank
@onready var ranks = $ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/ranks
@onready var animation_player = $AnimationPlayer
@onready var podium_container = $ScrollContainer/VBoxContainer/Control
@onready var podium =$ScrollContainer/VBoxContainer/Control/podium 
@onready var scroll_container = $ScrollContainer

func show_ranks():
	scroll_container.mouse_filter = MOUSE_FILTER_IGNORE
	
	_remove_child(top_rank)
	_remove_child(ranks)
	
	var top_3 :Array = []
	
	for i in 10:
		var rank_item = rank_item_scene.instantiate()
		rank_item.number = i + 1
		rank_item.level = 69
		rank_item.player = Global.player
		
		if i < 3:
			top_3.append({"level" : 69, "player" : Global.player})
			top_rank.add_child(rank_item)
		else:
			ranks.add_child(rank_item)
			
	podium.top_3 = top_3
	podium.show_rank()
	await get_tree().process_frame
	podium_container.custom_minimum_size = podium.size
	
	podium.enabler_visibler = false
	
	animation_player.play("show_rank")
	await animation_player.animation_finished
	
	podium.enabler_visibler = true
	scroll_container.mouse_filter = MOUSE_FILTER_PASS
	
func _on_visibility_changed():
	if podium:
		podium.enabler_visibler = visible
	
func _remove_child(node :Node):
	for i in node.get_children():
		node.remove_child(i)
		i.queue_free()
		
func _on_podium_on_podium_top_visible(is_visible :bool):
	if not is_visible:
		animation_player.play("show_top_rank")
	else:
		animation_player.play_backwards("show_top_rank")
















