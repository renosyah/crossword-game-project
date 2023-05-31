extends Control

signal play
signal rank
signal setting
signal back_press

@onready var animation_player = $AnimationPlayer
@onready var login_name = $login_notif/CenterContainer/HBoxContainer/VBoxContainer/login_name
@onready var login_email = $login_notif/CenterContainer/HBoxContainer/VBoxContainer/login_email
@onready var level = $VBoxContainer/level
@onready var back_button_container = $HBoxContainer2

var _can_back :bool = false

func show_menu(re_show :bool = false):
	level.text = "Level %s" % Global.level
	login_name.text = "Login as %s" % Global.player.player_name
	login_email.text = Global.player.player_email
	
	if re_show:
		animation_player.play("re_show_menu")
		return
		
	animation_player.play("show_menu")
	
func _on_play_pressed():
	animation_player.play("play")
	emit_signal("play")

func _on_setting_button_pressed():
	_can_back = true
	animation_player.play("to_setting")
	emit_signal("setting")

func _on_rank_button_pressed():
	_can_back = true
	animation_player.play("to_rank")
	emit_signal("rank")

func _on_back_button_pressed():
	if not _can_back:
		return
		
	_can_back = false
	emit_signal("back_press")
