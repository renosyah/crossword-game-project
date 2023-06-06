extends MarginContainer

@export var data :String
@onready var word = $HBoxContainer/MarginContainer/HBoxContainer/word

func _ready():
	word.text = data
