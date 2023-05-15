extends Control
class_name PopUpMessage

const color_error = Color(0.64705884456635, 0, 0, 0.74901962280273)

@onready var animation_player = $AnimationPlayer
@onready var message = $MarginContainer/VBoxContainer/message
@onready var title = $MarginContainer/VBoxContainer/title
@onready var color_rect = $MarginContainer/ColorRect
@onready var timer = $Timer

func show_popup_message(_title, _message :String, _color :Color = color_error):
	title.text = _title
	message.text = _message
	color_rect = _color
	
	animation_player.play("popup")
	timer.start()
	
func _on_timer_timeout():
	animation_player.play("popdown")
