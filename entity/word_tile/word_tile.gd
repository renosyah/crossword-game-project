extends MarginContainer
class_name WordTile

@export var id :String
@export var data :String
@export var is_show :bool

@onready var label = $Label

@onready var bg_empty = $bg_empty
@onready var bg = $bg
@onready var bg_solved = $bg_solved

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = ""
	
	bg_solved.visible = false
	
	bg.visible = not data.is_empty()
	bg_empty.visible = data.is_empty()
	
func show_data():
	is_show = true
	label.text = data.to_upper()
	
func solved():
	show_data()
	bg_solved.visible = true
	
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
