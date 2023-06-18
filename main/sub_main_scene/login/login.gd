extends Control

signal login_completed(_with)

@onready var animation_player = $AnimationPlayer
@onready var game_title = $mainIcon/game_title
@onready var sign_in_title = $panelLogin/VBoxContainer/sign_in_title
@onready var sign_in_description = $panelLogin/VBoxContainer/HBoxContainer2/sign_in_description
@onready var google_sign_in_button = $panelLogin/VBoxContainer/HBoxContainer/google_sign_in_button/CenterContainer/HBoxContainer/sign_in_button
@onready var google_play_sign_in_button = $panelLogin/VBoxContainer/HBoxContainer3/google_play_sign_in_button/CenterContainer/HBoxContainer/sign_in_button
@onready var label_or = $panelLogin/VBoxContainer/CenterContainer/Label

@onready var sfx = Global.sfx

var play_service_player :PlayService.User

func _ready():
	OAuth2.sign_in_completed.connect(_sign_in_completed)
	PlayService.on_sign_in_success.connect(_on_sign_in_success)
	
	game_title.text = tr("GAME_TITLE")
	sign_in_title.text = tr("SIGN_IN_TITLE")
	sign_in_description.text = tr("SIGN_IN_DESCRIPTION")
	google_sign_in_button.text = tr("SIGN_IN_BUTTON")
	google_play_sign_in_button.text = tr("SIGN_IN_BUTTON_GOOGLE_PLAY")
	label_or.text = tr("OR")
	
	animation_player.play("RESET")
	
func _sign_in_completed():
	await hide_login_form()
	
	emit_signal("login_completed", "google")
	
func _on_sign_in_success(_user :PlayService.User):
	await hide_login_form()
	play_service_player = _user
	emit_signal("login_completed", "google_play_service")
	
func show_icon():
	animation_player.play("show_icon")
	
func show_login_form():
	animation_player.play("show_login_form")
	await animation_player.animation_finished
	
func _on_google_sign_in_button_pressed():
	sfx.stream = preload("res://assets/sound/click.wav")
	sfx.play()
	
	OAuth2.sign_in()
	
func _on_google_play_sign_in_button_pressed():
	sfx.stream = preload("res://assets/sound/click.wav")
	sfx.play()
	
	PlayService.signIn()
	
func hide_login_form():
	animation_player.play_backwards("show_login_form")
	await animation_player.animation_finished
	
	animation_player.play_backwards("show_icon")
	await animation_player.animation_finished



