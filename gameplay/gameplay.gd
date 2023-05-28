extends Node

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			on_back_pressed()
			return
			
		NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

