extends Control

signal watch_ads(is_aggree)

@export var title :String
@export var description :String

@onready var _title = $MarginContainer/VBoxContainer/title
@onready var _description = $MarginContainer/VBoxContainer/HBoxContainer2/description
@onready var _animation_player = $AnimationPlayer

func show_panel():
	mouse_filter = Control.MOUSE_FILTER_STOP
	_title.text = title
	_description.text = description
	_animation_player.play("show_panel")
	
func _on_watch_ads_button_pressed():
	_animation_player.play("RESET")
	emit_signal("watch_ads", true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_no_button_pressed():
	_animation_player.play_backwards("show_panel")
	emit_signal("watch_ads", false)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
