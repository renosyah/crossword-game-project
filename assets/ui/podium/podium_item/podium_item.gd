extends VBoxContainer

var number :int
var level :int
var player_id :String
var player_name :String
var player_avatar :String

@onready var _player_level = $MarginContainer2/player_level
@onready var _avatar = $MarginContainer/Panel2/avatar
@onready var _player_name = $player_name
@onready var _crown = $crown

# Called when the node enters the scene tree for the first time.
func _ready():
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
		
		
		
		
		
