extends BaseData
class_name PlayerData

signal avatar_image

@export var player_id :String = ""
@export var player_name :String = ""
@export var player_email :String = ""
@export var player_avatar :String = ""

func from_dictionary(data : Dictionary):
	super.from_dictionary(data)
	player_id = data["player_id"]
	player_name = data["player_name"]
	player_email = data["player_email"]
	player_avatar = data["player_avatar"]
	
func to_dictionary() -> Dictionary:
	var data : Dictionary = {}
	data["player_id"] = player_id
	data["player_name"] = player_name
	data["player_email"] = player_email
	data["player_avatar"] = player_avatar
	return data
	
