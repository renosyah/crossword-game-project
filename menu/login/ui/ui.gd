extends Control

@onready var loading = $CanvasLayer/Control/loading

func _ready():
	OAuth2.sign_in_completed.connect(_sign_in_completed)
	OAuth2.sign_in_expired.connect(_sign_in_expired)
	
	OAuth2.check_sign_in_status()
	loading.visible = true
	
func _sign_in_completed():
	loading.visible = false
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")
	
func _sign_in_expired():
	loading.visible = false
	
func _on_login_pressed():
	if loading.visible:
		return
		
	loading.visible = true
	OAuth2.sign_in()
	
