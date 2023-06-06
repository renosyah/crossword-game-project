extends Control

signal play
signal rank
signal logout
signal back_press

@onready var animation_player = $AnimationPlayer
@onready var login_name = $login_notif/CenterContainer/HBoxContainer/VBoxContainer/login_name
@onready var login_email = $login_notif/CenterContainer/HBoxContainer/VBoxContainer/login_email
@onready var level = $VBoxContainer/level
@onready var back_button_container = $HBoxContainer2

@onready var rank_label = $rank_button/MarginContainer/HBoxContainer/VBoxContainer/rank_label
@onready var setting_label = $setting_button/MarginContainer/HBoxContainer/VBoxContainer/setting_label
@onready var game_title = $VBoxContainer/game_title
@onready var play_label = $VBoxContainer/HBoxContainer/play/HBoxContainer/play_label
@onready var play_button = $VBoxContainer/HBoxContainer/play

@onready var rank_container = $rank_button/MarginContainer
@onready var setting_container = $setting_button/MarginContainer

@onready var mute_icon = $mute_button/MarginContainer/VBoxContainer/mute_icon
@onready var mute_label = $mute_button/MarginContainer/VBoxContainer/mute_label

@onready var panel_logout = $panel_logout

var _is_mutted :bool = false
var _can_back :bool = false
var _tween :Tween

func _ready():
	game_title.text = tr("GAME_TITLE")
	play_label.text = tr("PLAY")
	rank_label.text = tr("RANK")
	setting_label.text = tr("SETTING")
	
	play_button.pivot_offset = play_button.size / 2
	
	_check_is_mute()
	
func show_menu(re_show :bool = false):
	var size_max_x = max(rank_container.size.x, setting_container.size.x)
	rank_container.custom_minimum_size.x = size_max_x
	setting_container.custom_minimum_size.x = size_max_x
	
	level.text = "%s %s" % [tr("LEVEL") ,Global.level]
	login_name.text = "%s %s" % [tr("SIGNED_IN_AS"),Global.player.player_name] 
	login_email.text = Global.player.player_email
	
	if re_show:
		animation_player.play("re_show_menu")
		return
		
	animation_player.play("show_menu")

func _on_play_pressed():
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	play_button.scale = Vector2.ONE * 0.8
	_tween.tween_property(play_button, "scale", Vector2.ONE, 0.2)
	
	animation_player.play("play")
	emit_signal("play")

func _on_setting_button_pressed():
	_can_back = true
	animation_player.play("to_setting")
	panel_logout.show_panel_logout()
	
func _on_panel_logout_close():
	animation_player.play("re_show_menu")
	
func _on_rank_button_pressed():
	_can_back = true
	animation_player.play("to_rank")
	emit_signal("rank")
	
func _on_back_button_pressed():
	if not _can_back:
		return
		
	_can_back = false
	emit_signal("back_press")
	
	
func _on_button_mute_pressed():
	_is_mutted = not _is_mutted
	AudioServer.set_bus_mute(0, _is_mutted)
	_check_is_mute()
	
func _check_is_mute():
	if _is_mutted:
		mute_icon.texture = preload("res://assets/ui/icons/unmute.png")
		mute_label.text = tr("UNMUTE")
	else:
		mute_icon.texture = preload("res://assets/ui/icons/mute.png")
		mute_label.text = tr("MUTE")
		
		
func _on_panel_logout_logout():
	emit_signal("logout")



