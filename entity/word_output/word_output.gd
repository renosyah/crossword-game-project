extends MarginContainer
class_name WordOutput

@export var data :String

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = data.to_upper()
