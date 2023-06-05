extends Control

signal watch_ads(is_aggree)

@export var title :String
@export var description :String
@export var button_title :String

@onready var _title = $MarginContainer/VBoxContainer/title
@onready var _description = $MarginContainer/VBoxContainer/HBoxContainer2/description
@onready var _animation_player = $AnimationPlayer
@onready var _button_title = $MarginContainer/VBoxContainer/HBoxContainer/watch_ads_button/CenterContainer/HBoxContainer/button_title
@onready var _no = $MarginContainer/VBoxContainer/HBoxContainer3/no_button/CenterContainer/no

func _ready():
	_no.text = tr("NO")

func show_panel():
	mouse_filter = Control.MOUSE_FILTER_STOP
	_title.text = title
	_description.text = description
	_button_title.text = button_title
	_animation_player.play("show_panel")
	
func _on_watch_ads_button_pressed():
	_animation_player.play("RESET")
	emit_signal("watch_ads", true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_no_button_pressed():
	_animation_player.play_backwards("show_panel")
	emit_signal("watch_ads", false)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
