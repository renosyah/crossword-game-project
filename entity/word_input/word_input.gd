extends MarginContainer
class_name WordInput

signal on_press(data)

@export var data :String

@onready var label = $Button/Label
@onready var button = $Button

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = data.to_upper()
	
func _on_button_pressed():
	emit_signal("on_press", data)
