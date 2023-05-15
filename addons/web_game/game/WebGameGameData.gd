extends Node
class_name WebGameGameData

@export var id :int
@export var game_name :String

func from_dictionary(data : Dictionary):
	id = data["id"]
	game_name = data["game_name"]

func to_dictionary() -> Dictionary :
	var data = {}
	data["id"] = id
	data["game_name"] = game_name
	return data

