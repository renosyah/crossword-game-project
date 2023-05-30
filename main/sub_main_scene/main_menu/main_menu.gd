extends Control

signal play
signal rank
signal setting

@onready var animation_player = $AnimationPlayer
@onready var login_name = $login_notif/CenterContainer/HBoxContainer/VBoxContainer/login_name

func show_menu():
	login_name.text = "Login as %s" % Global.player_name
	animation_player.play("show_menu")

func _on_play_pressed():
	animation_player.play("play")
	emit_signal("play")

func _on_setting_button_pressed():
	emit_signal("setting")

func _on_rank_button_pressed():
	animation_player.play("to_rank")
	emit_signal("rank")
