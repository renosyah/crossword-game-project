extends MarginContainer
class_name WordTile

@export var id :String
@export var data :String
@export var is_show :bool
@export var is_solved :bool

@onready var label = $Control/Panel/Label
@onready var panel_style :StyleBoxFlat = $Control/Panel.get_theme_stylebox(StringName("panel")).duplicate()
@onready var panel = $Control/Panel

@onready var audio_stream_player = $AudioStreamPlayer

var tween :Tween

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
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	panel.scale = Vector2.ONE * 1.3
	tween.tween_property(panel, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_BOUNCE)
	
	audio_stream_player.stream = preload("res://assets/sound/pop.wav")
	audio_stream_player.play()
	
	show_data()
	
func tile_size_updated():
	label.add_theme_font_size_override("font_size", custom_minimum_size.x * 0.8)
