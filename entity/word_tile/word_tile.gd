extends MarginContainer
class_name WordTile

@export var id :String
@export var data :String
@export var is_show :bool

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = ""
	
func show_data():
	is_show = true
	label.text = data.to_upper()
	
func solved():
	show_data()
	
func tile_size_updated():
	var size = 32
	if custom_minimum_size.x < 50 and custom_minimum_size.x >= 40:
		size = 24
	elif custom_minimum_size.x < 40 and custom_minimum_size.x >= 30:
		size = 16
	elif custom_minimum_size.x < 30 and custom_minimum_size.x >= 20:
		size = 14
	elif custom_minimum_size.x < 20:
		size = 8
		
	label.add_theme_font_size_override("font_size",size)
