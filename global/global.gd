extends Node
######################################################################

const player_data_file = "player.data"

@onready var wordData :WordsData = WordsData.new()
@onready var player :PlayerData = PlayerData.new()

@onready var level :int = 1
@onready var words_count :int = 5
@onready var word_list :Array = []
@onready var word_list_founded :Array= []

func _ready():
	wordData.difficulty = wordData.easy
	wordData.load_words_data()
	
	player.load_data(player_data_file)
	
	setup_regenerate_hp_hint()

func reset_player():
	level = 1
	
func generate_words():
	word_list.clear()
	word_list_founded.clear()
	
	var list = []
	var count = 0
	
	words_count = 5
	
	var input = level
	while (input >= 10 and input % 10 == 0):
		input = input / 10;
		words_count += 2

	words_count = clamp(words_count, 5, 25)
	
	while count < words_count:
		randomize()
		var words :Array = wordData.dictionaries[wordData.dictionaries.keys().pick_random()]
		var word = words.pick_random()
		if list.has(word):
			continue
			
		list.append(word)
		count += 1
		
	for i in list:
		word_list.append([i, "clue"])
	
######################################################################

var regenerate_hp_hint :RegenerateHpHint

func setup_regenerate_hp_hint():
	regenerate_hp_hint = preload("res://assets/regenerate_hp_hint/regenerate_hp_hint.tscn").instantiate()
	regenerate_hp_hint.error.connect(_regenerate_hp_hint_error)
	regenerate_hp_hint.ready_to_regenerate.connect(_regenerate_hp_hint_ready_to_regenerate)
	regenerate_hp_hint.regenerate_complete.connect(_regenerate_hp_hint_regenerate_complete)
	regenerate_hp_hint.one_second_pass.connect(_regenerate_hp_hint_one_second_pass)
	add_child(regenerate_hp_hint)
	
func _regenerate_hp_hint_one_second_pass():
	pass
	
func _regenerate_hp_hint_ready_to_regenerate():
	pass
	
func _regenerate_hp_hint_regenerate_complete():
	pass
	
func _regenerate_hp_hint_error(_msg :String):
	pass
	
######################################################################
@onready var image_cache :Dictionary = {}

func get_avatar_image(_node :Node, player :PlayerData) -> ImageTexture:
	if player.player_avatar.is_empty():
		return null
		
	if Global.image_cache.has(player.player_id):
		return image_cache[player.player_id]
		
	var http_request :HTTPRequest = HTTPRequest.new()
	_node.add_child(http_request)
	
	var http_error = http_request.request(player.player_avatar)
	if http_error != OK:
		http_request.queue_free()
		return null
		
	var result :Array = await http_request.request_completed
	if result[0] != HTTPRequest.RESULT_SUCCESS:
		return null
		
	http_request.queue_free()
	
	var img = Image.new()
	var image_error = img.load_jpg_from_buffer(result[3])
	if image_error != OK:
		return null
		
	image_cache[player.player_id] = ImageTexture.create_from_image(img)
	return image_cache[player.player_id]












