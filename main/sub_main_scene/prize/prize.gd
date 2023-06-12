extends Control

signal back

@onready var label = $VBoxContainer/HBoxContainer2/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = tr("PRIZE")

func _on_back_button_pressed():
	emit_signal("back")
