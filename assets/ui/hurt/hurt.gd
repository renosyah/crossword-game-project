extends Control

@export var color :Color = Color.RED

@onready var _border = $border
@onready var _animation_player= $AnimationPlayer

func _ready():
	_border.self_modulate = color
	_border.modulate.a = 0.0
	
func hide_hurt():
	_animation_player.stop(true)
	_border.modulate.a = 0.0
	
func show_hurt():
	if _animation_player.is_playing():
		return
		
	_animation_player.play("hurt")
	
func show_hurting():
	if _animation_player.is_playing():
		return
		
	_animation_player.play("hurting")
