extends VBoxContainer

@onready var player_level = $MarginContainer2/player_level
@onready var avatar = $MarginContainer/avatar
@onready var player_name = $player_name
@onready var crown = $crown

var number :int
var level :int
var player :PlayerData

# Called when the node enters the scene tree for the first time.
func _ready():
	player_name.text = player.player_name
	player_level.text = "Level %s" % level
	crown.texture = null
	match (number):
		1:
			crown.texture = preload("res://assets/ui/icons/rank_1.png")
		2:
			crown.texture = preload("res://assets/ui/icons/rank_2.png")
		3:
			crown.texture = preload("res://assets/ui/icons/rank_3.png")
			
	avatar.texture = await Global.get_avatar_image(self, player)

