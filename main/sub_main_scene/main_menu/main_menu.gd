extends Control

signal play
signal rank
signal setting

@onready var animation_player = $AnimationPlayer
@onready var login_name = $login_notif/CenterContainer/HBoxContainer/VBoxContainer/login_name
@onready var level = $VBoxContainer/level

func show_menu(re_show :bool = false):
	if re_show:
		animation_player.play("re_show_menu")
		return
		
	level.text = "Level %s" % Global.level
	login_name.text = "Login as %s" % Global.player.player_name
	animation_player.play("show_menu")

func _on_play_pressed():
	animation_player.play("play")
	emit_signal("play")

func _on_setting_button_pressed():
	emit_signal("setting")

func _on_rank_button_pressed():
	animation_player.play("to_rank")
	emit_signal("rank")
