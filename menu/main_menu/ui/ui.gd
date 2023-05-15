extends Control

@onready var score = $CanvasLayer/Control/score
@onready var label = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	score.visible = false
	var profile :Dictionary = await OAuth2.get_profile_info()
	if profile.is_empty():
		return
		
	label.text = "Welcome : %s" % profile["given_name"]
	
func _on_play_pressed():
	Global.reset_player()
	Global.generate_words()
	get_tree().change_scene_to_file("res://gameplay/gameplay.tscn")

func _on_score_button_pressed():
	score.visible = true
	score.display_score(Global.get_scores())
