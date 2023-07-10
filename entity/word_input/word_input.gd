extends MarginContainer
class_name WordInput

signal on_press(button,data)

@export var data :String
@export var is_pressed :bool = false
@export var is_enable :bool = true

@onready var label = $CenterContainer/Button/Label
@onready var button = $CenterContainer/Button

var tween :Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	label.add_theme_font_size_override("font_size", custom_minimum_size.x * 0.8)
	label.text = data.to_upper()
	check_is_pressed()
	
func _on_button_pressed():
	if not is_enable:
		return
		
	is_pressed = not is_pressed
	check_is_pressed()
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	button.scale = Vector2.ONE * 0.8
	tween.tween_property(button, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE)
	
	emit_signal("on_press", self, data)

func check_is_pressed():
	modulate.a = 0.5 if is_pressed else 1.0
	
func check_is_enable():
	modulate.a = 0.5 if not is_enable else 1.0
