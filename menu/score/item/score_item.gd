extends MarginContainer
class_name ScoreItem

@export var number :int
var data :ScoreData

@onready var no = $VBoxContainer/MarginContainer3/HBoxContainer/no
@onready var level = $VBoxContainer/MarginContainer3/HBoxContainer/level
@onready var score = $VBoxContainer/MarginContainer3/HBoxContainer/score

# Called when the node enters the scene tree for the first time.
func _ready():
	no.text = str(number)
	level.text = "Level " + str(data.level)
	score.text = "Score : " + str(data.score)
