extends HBoxContainer

@export var level:int
@export var is_current :bool
@export var is_locked :bool
@export var is_odd :bool
@export var show_dot :bool

@onready var _bg =  $Control3/Control/bg
@onready var _border =  $Control3/Control/border
@onready var _locked = $Control3/Control/locked
@onready var _level = $Control3/Control/level
@onready var _dot = $Control3/dot

@onready var panel_bg_style :StyleBoxFlat = _bg.get_theme_stylebox(StringName("panel")).duplicate()
@onready var panel_border_style :StyleBoxFlat = _border.get_theme_stylebox(StringName("panel")).duplicate()

func _ready():
	_bg.remove_theme_stylebox_override("panel")
	_bg.add_theme_stylebox_override("panel", panel_bg_style)
	
	_border.remove_theme_stylebox_override("panel")
	_border.add_theme_stylebox_override("panel", panel_border_style)
	
	_dot.rotation = 0
	
	if is_odd:
		alignment = BoxContainer.ALIGNMENT_BEGIN
		_dot.rotation = deg_to_rad(30)
		
	else:
		alignment = BoxContainer.ALIGNMENT_END
		_dot.rotation = deg_to_rad(150)
		
	_dot.visible = show_dot
		
	
	if is_locked:
		panel_bg_style.bg_color = Color("#BBBBBB")
		panel_border_style.border_color = Color("#A5A5A5")
		
		_level.visible = false
		_locked.visible = true
		return
		
	_locked.visible = false
	_level.visible = true
	_level.text = "%s" % level
	
	panel_bg_style.bg_color = Color("#FFE4A2")
	panel_border_style.border_color = Color("#FFE4A2")
	_level.add_theme_color_override("font_color","#852346")
	
	if is_current:
		panel_bg_style.bg_color = Color("#000000")
		_level.add_theme_color_override("font_color", "#FFE4A2")
	

	
