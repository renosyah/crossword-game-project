extends Control

signal login_completed

@onready var animation_player = $AnimationPlayer
@onready var game_title = $mainIcon/game_title
@onready var sign_in_title = $panelLogin/VBoxContainer/sign_in_title
@onready var sign_in_description = $panelLogin/VBoxContainer/HBoxContainer2/sign_in_description
@onready var sign_in_button = $panelLogin/VBoxContainer/HBoxContainer/sign_in_button/CenterContainer/HBoxContainer/sign_in_button

@onready var sfx = Global.sfx

func _ready():
	OAuth2.sign_in_completed.connect(_sign_in_completed)
	
	game_title.text = tr("GAME_TITLE")
	sign_in_title.text = tr("SIGN_IN_TITLE")
	sign_in_description.text = tr("SIGN_IN_DESCRIPTION")
	sign_in_button.text = tr("SIGN_IN_BUTTON")
	
	animation_player.play("RESET")
	
func _sign_in_completed():
	await hide_login_form()
	
	emit_signal("login_completed")
	
func show_icon():
	animation_player.play("show_icon")
	
func show_login_form():
	animation_player.play("show_login_form")
	await animation_player.animation_finished
	
func _on_sign_in_button_pressed():
	sfx.stream = preload("res://assets/sound/click.wav")
	sfx.play()
	
	OAuth2.sign_in()

func hide_login_form():
	animation_player.play_backwards("show_login_form")
	await animation_player.animation_finished
	
	animation_player.play_backwards("show_icon")
	await animation_player.animation_finished
