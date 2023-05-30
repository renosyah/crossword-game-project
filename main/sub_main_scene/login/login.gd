extends Control

signal on_sign_in_press
signal login_form_show
signal login_form_hide

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("RESET")

func show_icon():
	animation_player.play("show_icon")
	
func show_login_form():
	animation_player.play("show_login_form")
	await animation_player.animation_finished
	
	emit_signal("login_form_show")
	
func _on_sign_in_button_pressed():
	emit_signal("on_sign_in_press")

func hide_login_form():
	animation_player.play_backwards("show_login_form")
	await animation_player.animation_finished
	
	animation_player.play_backwards("show_icon")
	await animation_player.animation_finished
	
	emit_signal("login_form_hide")
