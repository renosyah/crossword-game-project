extends Control
class_name AnimatedBackground

@onready var _animation_tree_playback = $AnimationTree.get("parameters/playback")

func _ready():
	_animation_tree_playback.travel("Start")

func set_stage(stage :int, extra :String = ""):
	_animation_tree_playback.travel("stage_%s%s" % [stage, extra])
	
