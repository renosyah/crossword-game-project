extends Control

signal on_sign_in_press

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("RESET")

func show_icon():
	animation_player.play("show_icon")
	
func show_login_form():
	animation_player.play("show_login_form")
	
func _on_sign_in_button_pressed():
	emit_signal("on_sign_in_press")
