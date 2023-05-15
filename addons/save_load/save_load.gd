extends Node
class_name SaveLoad

const prefix = "user://"

static func save(_filename: String, _data):
	var file = FileAccess.open(prefix + _filename, FileAccess.WRITE)
	file.store_var(_data, true)
	file.close()

static func load_save(_filename : String):
	if  FileAccess.file_exists(prefix + _filename):
		var file = FileAccess.open(prefix + _filename, FileAccess.READ)
		var _data = file.get_var(true)
		file.close()
		return _data
	return null

static func delete_save(_filename : String):
	DirAccess.remove_absolute(prefix + _filename)
