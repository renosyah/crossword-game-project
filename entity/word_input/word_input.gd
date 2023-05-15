extends MarginContainer
class_name WordInput

signal on_press( data)

@export var data :String

@onready var label = $Button/Label
@onready var button = $Button
@onready var bg_empty = $Button/bg_empty
@onready var bg = $Button/bg
var tween :Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	bg_empty.modulate.a = 0
	label.text = data.to_upper()
	
func _on_Button_pressed():
	if tween:
		tween.kill()
		
	tween = create_tween()
	bg_empty.modulate.a = 1
	tween.tween_property(bg_empty, "modulate:a", 0, 0.2).set_trans(Tween.TRANS_SINE)
	
	emit_signal("on_press", data)
