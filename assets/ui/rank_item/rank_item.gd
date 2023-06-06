extends MarginContainer
class_name RankItem

var number :int
var level :int
var player_id :String
var player_name :String
var player_avatar :String

@onready var _num = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/num
@onready var _avatar = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/MarginContainer/avatar
@onready var _player_name = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/player_name
@onready var _player_level = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/player_level
@onready var _crown = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/crown

# Called when the node enters the scene tree for the first time.
func _ready():
	_num.text = "%s." % number
	_player_name.text = player_name
	_player_level.text = "%s %s" % [tr("LEVEL") ,level]
	
	_crown.texture = null
	match (number):
		1:
			_crown.texture = preload("res://assets/ui/icons/rank_1.png")
		2:
			_crown.texture = preload("res://assets/ui/icons/rank_2.png")
		3:
			_crown.texture = preload("res://assets/ui/icons/rank_3.png")
			
	_avatar.texture = await Global.get_avatar_image(self, player_id, player_avatar)
		




