extends Control

@export var hp : int = 1
@export var max_hp : int = 1

@onready var hp_template = $Control/hp
@onready var holder = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	hp = max_hp
	display()
	
func display():
	for i in holder.get_children():
		holder.remove_child(i)
		i.queue_free()
		
	for i in range(hp):
		var _hp = hp_template.duplicate()
		_hp.visible = true
		holder.add_child(_hp)
