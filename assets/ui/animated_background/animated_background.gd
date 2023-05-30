extends Control
class_name AnimatedBackground

@onready var animation_player = $AnimationPlayer

func set_stage(stage :int, reverse :bool = false):
	if reverse:
		animation_player.play_backwards("stage_%s" % stage)
	else:
		animation_player.play("stage_%s" % stage)
	
