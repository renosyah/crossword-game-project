extends Node

@onready var ui = $ui

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)

	OAuth2.sign_in_completed.connect(_sign_in_completed)
	OAuth2.sign_in_expired.connect(_sign_in_expired)
	
	OAuth2.check_sign_in_status()
	
	# show loading
	
func _sign_in_completed():
	# hide loading
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")
	
func _sign_in_expired():
	# hide loading
	pass
	
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			on_back_pressed()
			return
			
		NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	get_tree().quit()
