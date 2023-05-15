extends Node
class_name WebGameScoreData

@export var id :int
@export var game_id :int
@export var player_id :String
@export var player_name :String
@export var score :int = 0

func from_dictionary(data : Dictionary):
	id = data["id"]
	game_id = data["game_id"]
	player_id = data["player_id"]
	player_name = data["player_name"]
	score = data["score"]

func to_dictionary() -> Dictionary :
	var data = {}
	data["id"] = id
	data["game_id"] = game_id
	data["player_id"] = player_id
	data["player_name"] = player_name
	data["score"] = score
	return data

