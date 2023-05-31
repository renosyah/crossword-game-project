extends MarginContainer
class_name WordTile

@export var id :String
@export var data :String
@export var is_show :bool
@export var is_solved :bool

@onready var label = $Label
@onready var panel_style :StyleBoxFlat = $Panel.get_theme_stylebox(StringName("panel")).duplicate()
@onready var panel = $Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	panel.remove_theme_stylebox_override("panel")
	panel.add_theme_stylebox_override("panel", panel_style)
	label.text = ""
	
func show_data():
	is_show = true
	label.text = data.to_upper()
	
func solved():
	is_solved = true
	panel_style.bg_color = Color("#FFE4A2")
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
