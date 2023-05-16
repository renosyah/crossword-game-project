extends Control

@onready var loading = $CanvasLayer/Control/loading
@onready var popup_message = $CanvasLayer/Control/popup_message

func _ready():
	loading.visible = true
	OAuth2.sign_in_completed.connect(_sign_in_completed)
	OAuth2.sign_in_expired.connect(_no_session_or_expired)
	OAuth2.no_session.connect(_no_session_or_expired)
	OAuth2.failed.connect(_failed)
	
	OAuth2.check_sign_in_status()
	
func _sign_in_completed():
	loading.visible = false
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")
	
func _no_session_or_expired():
	loading.visible = false
	
func _failed(message :String):
	loading.visible = false
	popup_message.show_popup_message("Error", message)
	
func _on_login_pressed():
	if loading.visible:
		return
		
	loading.visible = true
	OAuth2.sign_in()
	
