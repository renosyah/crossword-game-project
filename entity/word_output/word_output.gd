extends MarginContainer
class_name WordOutput

signal reach

@export var data :String
@export var speed :int = 875

var _target :Vector2
var _margin :float = 10.0
var _tween :Tween

@onready var trajectory = $trajectory
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = data.to_upper()
	trajectory.top_level = true
	set_process(false)
	
func animated(_to :Vector2):
	_target = _to
	trajectory.position = _target + Vector2(-global_position.distance_to(_target), 0)
	set_process(true)
	_tweener()
	
func _tweener():
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	_tween.tween_property(self, "scale" ,Vector2.ONE * 2.0, 0.7)
	await _tween.finished
	
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	_tween.tween_property(self, "scale" ,Vector2.ONE , 0.4)
	
func _process(delta):
	if position.distance_to(_target) < _margin:
		emit_signal("reach", self)
		set_process(false)
		return
		
	trajectory.position += trajectory.position.direction_to(_target) * speed * delta
	position += position.direction_to(trajectory.position) * speed * delta
