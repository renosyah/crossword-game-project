extends MarginContainer
class_name RankItem

var number :int
var level :int
var player :PlayerData

@onready var num = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/num
@onready var avatar = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/MarginContainer/avatar
@onready var player_name = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/player_name
@onready var player_level = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/player_level
@onready var crown = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/crown

# Called when the node enters the scene tree for the first time.
func _ready():
	num.text = "%s." % number
	player_name.text = player.player_name
	player_level.text = "%s %s" % [tr("LEVEL") ,level]
	
	crown.texture = null
	match (number):
		1:
			crown.texture = preload("res://assets/ui/icons/rank_1.png")
		2:
			crown.texture = preload("res://assets/ui/icons/rank_2.png")
		3:
			crown.texture = preload("res://assets/ui/icons/rank_3.png")
			
	avatar.texture = await Global.get_avatar_image(self, player)
		




