extends Node
class_name WordsData

const alphabet = "abcdefghijklmnopqrstuvwxyz"
const kids = "dictionaries_kids"
const easy = "dictionaries_easy"
const hard = "dictionaries_hard"

@export var difficulty :String = easy

var dictionaries :Dictionary

func load_words_data():
	if difficulty.is_empty():
		return
		
	dictionaries.clear()
		
	for i in alphabet:
		var key = str(i).to_upper()
		var path = "res://data/words_data/{difficulty}/{key}.csv".format({"difficulty":difficulty,"key":key})
		if not FileAccess.file_exists(path):
			continue
			
		var file = FileAccess.open(path, FileAccess.READ)
		while !file.eof_reached():
			var csv = file.get_csv_line()
			if dictionaries.has(key):
				dictionaries[key].append(csv[0])
			else:
				dictionaries[key] = [csv[0]]
			
		file.close()
	

func is_in_dictionary(word :String) -> bool:
	if word.is_empty() or dictionaries.is_empty():
		return false
		
	var first_character :String = str(word[0]).to_upper()
	if not dictionaries.has(first_character):
		return false
		
	for i in dictionaries[first_character]:
		if i.to_upper() == word.to_upper():
			return true
			
	return false
	
#static func load_and_store():
#	var words = []
#	var file = FileAccess.open("res://data/DatasetMudahTTS.csv", FileAccess.READ)
#	while !file.eof_reached():
#		var csv = file.get_csv_line()
#		words.append(csv[0])
#
#	file.close()
#
#	var dictionary :Dictionary = {}
#	for i in words:
#		var key = str(i[0]).to_upper()
#		if dictionary.has(key):
#			dictionary[key].append(i)
#		else:
#			dictionary[key] = [i]
#
#	for key in dictionary.keys():
#		var _file = FileAccess.open(
#			"res://data/words_data/dictionaries_kids/{index}.csv".format({"index" : key}), FileAccess.WRITE
#		)
#		for word in dictionary[key]:
#			_file.store_csv_line([word])
#
#		_file.close()
#
#		var _file_import = FileAccess.open(
#			"res://data/words_data/dictionaries_kids/{index}.csv.import".format({"index" : key}), FileAccess.WRITE
#		)
#		_file_import.store_line("[remap]\nimporter=\"keep\"\n")
#		_file_import.close()
	
	
	
	
	
	
	
	
