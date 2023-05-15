extends BaseData
class_name ScoreData

@export var level : int = 0
@export var score : int = 0

func from_dictionary(data : Dictionary):
	super.from_dictionary(data)
	level = data["level"]
	score = data["score"]
	
func to_dictionary() -> Dictionary:
	var data : Dictionary = {}
	data["level"] = level
	data["score"] = score
	return data
	
