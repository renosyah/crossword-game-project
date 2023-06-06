extends Control

signal retry

@export var error_title :String
@export var error_description :String

@onready var _error_title = $CenterContainer/HBoxContainer/VBoxContainer/error_title
@onready var _error_description = $CenterContainer/HBoxContainer/VBoxContainer/error_description
@onready var _animation_player = $AnimationPlayer
@onready var _label_retry = $CenterContainer/HBoxContainer/VBoxContainer/retry/CenterContainer/HBoxContainer/Label

func show_error():
	_error_title.text = error_title
	_error_description.text = error_description
	_label_retry.text = tr("RETRY")
	_animation_player.play("show_error")
	
func _on_retry_pressed():
	emit_signal("retry")
