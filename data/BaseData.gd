extends Resource
class_name BaseData

func from_dictionary(data : Dictionary):
	pass
	
func to_dictionary() -> Dictionary:
	return {}
	
func is_empty() -> bool:
	return to_dictionary().is_empty()
	
func save_data(filename : String):
	var data = to_dictionary()
	SaveLoad.save(filename,data)
	
func load_data(filename : String):
	var data  = SaveLoad.load_save(filename)
	if data == null:
		return
		
	from_dictionary(data)
	
func delete_data(filename : String):
	SaveLoad.delete_save(filename)
