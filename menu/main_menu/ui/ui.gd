extends Control

@onready var score = $CanvasLayer/Control/score
@onready var label = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	score.visible = false
	label.visible = false
	
	OAuth2.get_profile.connect(_get_profile)
	OAuth2.sign_out_completed.connect(_sign_out_completed)
	OAuth2.get_profile_info()
	
func _get_profile(profile :Dictionary):
	if profile.is_empty():
		return
		
	label.visible = true
	label.text = "Welcome : %s" % profile["given_name"]
	
func _sign_out_completed():
	get_tree().change_scene_to_file("res://menu/login/login.tscn")
	
func _on_play_pressed():
	Global.reset_player()
	Global.generate_words()
	get_tree().change_scene_to_file("res://gameplay/gameplay.tscn")

func _on_score_button_pressed():
	score.visible = true
	score.display_score(Global.get_scores())

func _on_sign_out_pressed():
	OAuth2.sign_out()
