extends Control
class_name PopUpMessage

signal on_popup_closed
signal on_all_popup_closed

const color_error = Color(0.64705884456635, 0, 0, 0.74901962280273)
const color_success = Color(0.14117647707462, 0.49803921580315, 0, 0.74901962280273)

@export var display_time :float = 4.0

@onready var animation_player = $AnimationPlayer
@onready var message = $MarginContainer/VBoxContainer/message
@onready var title = $MarginContainer/VBoxContainer/title
@onready var color_rect = $MarginContainer/ColorRect
@onready var timer = $Timer

var _queue_messages :Array = []
var _queue_run :bool = false

func _ready():
	timer.wait_time = display_time

func show_popup_message(_title, _message :String, _color :Color = color_error):
	_queue_messages.append({"title" : _title, "message" : _message, "color" : _color})
	
	if _queue_run:
		return
		
	_queue_run = true
	
	_display_in_queue_message()
	
func _show_popup_message(_title, _message :String, _color :Color = color_error):
	title.text = _title
	message.text = _message
	color_rect.color = _color
	
	animation_player.play("popup")
	await animation_player.animation_finished
	
	timer.start()
	await timer.timeout
	
	animation_player.play("popdown")
	await animation_player.animation_finished
	
	emit_signal("on_popup_closed")
	
func _display_in_queue_message():
	while not _queue_messages.is_empty():
		var data = _queue_messages[0]
		_show_popup_message(data["title"], data["message"], data["color"])
		await self.on_popup_closed
		_queue_messages.remove_at(0)
	
	_queue_run = false
	emit_signal("on_all_popup_closed")


