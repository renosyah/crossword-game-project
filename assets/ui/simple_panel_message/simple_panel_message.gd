extends Control
class_name SimplePanelMessage

@export var title :String
@export var message :String

@onready var _title = $PanelLogout/VBoxContainer/HBoxContainer2/VBoxContainer/title
@onready var _message = $PanelLogout/VBoxContainer/HBoxContainer2/VBoxContainer/message
@onready var _animation_player = $AnimationPlayer
@onready var _color_rect = $ColorRect

func show_panel():
	_color_rect.mouse_filter = MOUSE_FILTER_STOP
	_title.text = title
	_message.text = message
	_animation_player.play("show_panel")
	
func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		_on_close_pressed()
		
func _on_close_pressed():
	_animation_player.play_backwards("show_panel")
	_color_rect.mouse_filter = MOUSE_FILTER_IGNORE
