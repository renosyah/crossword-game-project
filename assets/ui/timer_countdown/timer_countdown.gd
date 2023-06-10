extends Control
class_name TimerCountDown

signal timeout

@export var wait_time: int = 300
var is_started :bool = false

@onready var label_time = $VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/label_time
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

func _ready():
	is_started = false
	label_time.pivot_offset = label_time.size / 2

func start():
	is_started = true
	label_time.text = format_time(wait_time, FORMAT_MINUTES | FORMAT_SECONDS)
	timer.start()
	
func stop():
	if timer.is_stopped():
		return
		
	timer.stop()
	
func _on_timer_timeout():
	wait_time -= 1
	label_time.text = format_time(wait_time, FORMAT_MINUTES | FORMAT_SECONDS)
	
	if wait_time == 0:
		is_started = false
		emit_signal("timeout")
		return
		
	if wait_time < 10:
		animation_player.play("flip_flop")
		
	timer.start()
	
#--------------------------------------------------------------------------------------------------
enum {
	FORMAT_HOURS   = 1 << 0,
	FORMAT_MINUTES = 1 << 1,
	FORMAT_SECONDS = 1 << 2,
	FORMAT_DEFAULT = FORMAT_HOURS | FORMAT_MINUTES | FORMAT_SECONDS
}

func format_time(time, format = FORMAT_DEFAULT, digit_format = "%02d", colon = ":"):
	var digits = []
	
	if format & FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)
	
	if format & FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)
	
	if format & FORMAT_SECONDS:
		var seconds = digit_format % [int(ceil(time)) % 60]
		digits.append(seconds)
	
	var formatted = String()
	
	for digit in digits:
		formatted += digit + colon

	if not formatted.is_empty():
		formatted = formatted.rstrip(colon)

	return formatted
