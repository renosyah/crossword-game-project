extends Control

@onready var score = $CanvasLayer/Control/score
@onready var label = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/Label
@onready var loading = $CanvasLayer/Control/loading
@onready var popup_message = $CanvasLayer/Control/popup_message

# Called when the node enters the scene tree for the first time.
func _ready():
	score.visible = false
	loading.visible = true
	
	OAuth2.profile_info.connect(_profile_info)
	OAuth2.sign_out_completed.connect(_sign_out_completed)
	OAuth2.failed.connect(_failed)
	
	if Global.player_id.is_empty():
		OAuth2.get_profile_info()
		
	else:
		loading.visible = false
		label.text = "Welcome : %s" % Global.player_name
		
func _profile_info(profile : OAuth2.OAuth2UserInfo):
	loading.visible = false
	Global.player_id = profile.id
	Global.player_name = profile.given_name
	
	label.text = "Welcome : %s" % Global.player_name
	
func _sign_out_completed():
	loading.visible = false
	get_tree().change_scene_to_file("res://menu/login/login.tscn")
	
func _failed(message :String):
	loading.visible = false
	popup_message.show_popup_message("Error", message)
	
func _on_play_pressed():
	Global.reset_player()
	Global.generate_words()
	get_tree().change_scene_to_file("res://gameplay/gameplay.tscn")
	
func _on_score_button_pressed():
	score.visible = true
	score.display_score(Global.get_scores())
	
func _on_sign_out_pressed():
	if loading.visible:
		return
		
	loading.visible = true
	OAuth2.sign_out()




