extends CenterContainer

@onready var ok = $MarginContainer/ok
@onready var wrong = $MarginContainer/wrong
@onready var animation_player = $AnimationPlayer

func _hide_all():
	ok.visible = false
	wrong.visible = false
	animation_player.current_animation = "popup"
	
func show_ok():
	_hide_all()
	ok.visible = true
	animation_player.play()
	
func show_wrong():
	_hide_all()
	wrong.visible = true
	animation_player.play()
