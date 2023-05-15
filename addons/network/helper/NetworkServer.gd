extends NetworkConfiguration
class_name NetworkServer

@export var max_player :int = 4

func from_dictionary(data : Dictionary):
	super.from_dictionary(data)
	max_player = data["max_player"]
	
func to_dictionary() -> Dictionary :
	var data = super.to_dictionary()
	data["max_player"] = max_player
	return data
	
