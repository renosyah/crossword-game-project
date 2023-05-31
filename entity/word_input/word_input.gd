extends MarginContainer
class_name WordInput

signal on_press(data)

@export var data :String

@onready var label = $CenterContainer/Button/Label
@onready var button = $CenterContainer/Button

var tween :Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = data.to_upper()
	
func _on_button_pressed():
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	button.scale = Vector2.ONE * 0.8
	tween.tween_property(button, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE)
	
	emit_signal("on_press", data)
