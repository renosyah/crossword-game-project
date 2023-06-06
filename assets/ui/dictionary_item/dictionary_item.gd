extends MarginContainer

@export var data :String
@onready var word = $HBoxContainer/VBoxContainer/word

func _ready():
	word.text = data.capitalize()
