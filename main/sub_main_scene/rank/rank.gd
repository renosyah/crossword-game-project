extends Control

const rank_item_scene = preload("res://assets/ui/rank_item/rank_item.tscn")
@onready var label = $VBoxContainer/HBoxContainer2/Label

@onready var top_rank = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/top_rank_container/top_rank
@onready var ranks = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/ranks
@onready var animation_player = $AnimationPlayer
@onready var podium_container = $VBoxContainer/ScrollContainer/VBoxContainer/Control
@onready var podium =$VBoxContainer/ScrollContainer/VBoxContainer/Control/podium 
@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var loading = $loading

var _rank_offset :int = 0
var _rank_limit :int = 10
var _on_request_rank :bool = false
var _top_3 :Array = []

var _enabler_visibler :bool = false

func _ready():
	loading.visible = true
	label.text = tr("RANK").to_upper()
	Global.rank_api.ranks.connect(_on_ranks)

func show_ranks():
	animation_player.play("RESET")
	loading.visible = true
	_enabler_visibler = false
	_rank_offset = 0
	_top_3.clear()
	_remove_child(top_rank)
	_remove_child(ranks)
	
	if _top_3.is_empty():
		Global.rank_api.request_list_ranks(_rank_offset, _rank_limit)
		
	else:
		loading.visible = false
		
		scroll_container.mouse_filter = MOUSE_FILTER_IGNORE
		
		await get_tree().process_frame
		podium_container.custom_minimum_size = podium.size
		
		_enabler_visibler = false
		
		animation_player.play("show_rank")
		await animation_player.animation_finished
		
		_enabler_visibler = true
		
		scroll_container.mouse_filter = MOUSE_FILTER_PASS
	
func _remove_child(node :Control):
	for i in node.get_children():
		node.remove_child(i)
		i.queue_free()
		
	node.custom_minimum_size.y = 0
		
func _on_visible_on_screen_notifier_2d_screen_entered():
	if not _enabler_visibler or not visible:
		return
		
	animation_player.play_backwards("show_top_rank")
	if podium:
		podium.show_podium()
	
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	if not _enabler_visibler or not visible:
		return
		
	animation_player.play("show_top_rank")
	if podium:
		podium.hide_podium()

func _on_scroll_container_scroll_ended():
	if _on_request_rank:
		return
		
	_on_request_rank = true
	_rank_offset += _rank_limit
	
	Global.rank_api.request_list_ranks(_rank_offset, _rank_limit)

func _on_ranks(_ok :bool, datas :Array):
	_on_request_rank = false

	var is_first_page :bool = _rank_offset == 0
	if is_first_page:
		scroll_container.mouse_filter = MOUSE_FILTER_IGNORE
		
	for i in datas:
		var pos :int = top_rank.get_child_count() + ranks.get_child_count()
		var item :RanksApi.Rank = i
		var rank_item = rank_item_scene.instantiate()
		rank_item.number = pos + 1
		rank_item.level = item.rank_level
		rank_item.player_id = item.player_id
		rank_item.player_name = item.player_name
		rank_item.player_avatar = item.player_avatar
		
		if pos < 3 and is_first_page:
			_top_3.append(item)
			top_rank.add_child(rank_item)
			
		else:
			ranks.add_child(rank_item)
			
		
	if is_first_page:
		loading.visible = false
		
		podium.top_3 = _top_3
		podium.show_rank()
	
		await get_tree().process_frame
		podium_container.custom_minimum_size = podium.size
	
		_enabler_visibler = false
	
		animation_player.play("show_rank")
		await animation_player.animation_finished
	
		_enabler_visibler = true
	
		scroll_container.mouse_filter = MOUSE_FILTER_PASS














