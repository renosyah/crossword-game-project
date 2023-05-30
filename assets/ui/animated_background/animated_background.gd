extends Control
class_name AnimatedBackground

signal stage_finish

@onready var animation_player = $AnimationPlayer

func set_stage(stage :int, reverse :bool = false):
	if reverse:
		animation_player.play_backwards("stage_%s" % stage)
	else:
		animation_player.play("stage_%s" % stage)
		
	await animation_player.animation_finished
	emit_signal("stage_finish")
	
