extends Control

const item_scene = preload("res://assets/ui/level_displayer/level_item/level_item.tscn")
@onready var holder_container = $HBoxContainer/ScrollContainer/VBoxContainer/VBoxContainer
@onready var scroll_container = $HBoxContainer/ScrollContainer

var offset = 0
var limit = 10

func display_level():
	limit = Global.level + limit
	_display_level()
	
func _display_level():
	var scroll_offset = 0
	
	for i in range(offset, offset + limit, 1):
		if i < 0:
			continue
			
		var level = i + 1
		var item = item_scene.instantiate()
		item.level = level
		item.is_locked = level > Global.level
		item.is_current = level == Global.level
		item.is_odd = level % 2 != 0
		item.show_dot = level > 1
		holder_container.add_child(item)
		holder_container.move_child(item, 0)
		
		if item.is_locked:
			scroll_offset += 90
		
	await get_tree().process_frame
	scroll_offset -= 300
	scroll_container.scroll_vertical = scroll_offset

func _on_visible_on_screen_notifier_2d_screen_entered():
	offset += limit
	_display_level()















