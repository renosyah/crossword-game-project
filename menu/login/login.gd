extends Node

@onready var ui = $ui

# Called when the node enters the scene tree for the first time.
func _ready():
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
