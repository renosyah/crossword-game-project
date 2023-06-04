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
	setup_sound()

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

signal setup_regenerate_complete(has_error)

var current_time :CurrentTime
var regenerate_hp :RegenerateItemHandler
var regenerate_hint :RegenerateItemHandler
var regenerate_reward_hp :RegenerateItemHandler
var regenerate_reward_hint :RegenerateItemHandler

func setup_regenerate_hp_hint():
	current_time = preload("res://assets/current_time/current_time.tscn").instantiate()
	current_time.current_time.connect(_current_time_ready)
	current_time.error.connect(_current_time_error)
	
	var scene = preload("res://assets/regenerate_item_handler/regenerate_item_handler.tscn")
	regenerate_hp = scene.instantiate()
	regenerate_hp.item_name = "hp"
	regenerate_hp.item_count = 5
	regenerate_hp.item_max = 5
	
	regenerate_hint = scene.instantiate()
	regenerate_hint.item_name = "hint"
	regenerate_hint.item_count = 10
	regenerate_hint.item_max = 10
	
	regenerate_reward_hp = scene.instantiate()
	regenerate_reward_hp.item_name = "free_hp_reward_ads"
	regenerate_reward_hp.item_count = 1
	regenerate_reward_hp.item_max = 1
	
	regenerate_reward_hint = scene.instantiate()
	regenerate_reward_hint.item_name = "free_hint_reward_ads"
	regenerate_reward_hint.item_count = 1
	regenerate_reward_hint.item_max = 1
	
	add_child(current_time)
	add_child(regenerate_hp)
	add_child(regenerate_hint)
	add_child(regenerate_reward_hp)
	add_child(regenerate_reward_hint)
	
func _current_time_ready(_current_time :Dictionary):
	regenerate_hp.run_regenerating(_current_time)
	regenerate_hint.run_regenerating(_current_time)
	regenerate_reward_hp.run_regenerating(_current_time)
	regenerate_reward_hint.run_regenerating(_current_time)
	emit_signal("setup_regenerate_complete", false)
	
func _current_time_error(_msg :String):
	emit_signal("setup_regenerate_complete", true)
	
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
	
######################################################################
# sound
var music :AudioStreamPlayer
var sfx :AudioStreamPlayer

func setup_sound():
	var music_stream :AudioStream = preload("res://assets/sound/music.mp3")
	music_stream.loop = true
	music_stream.loop_offset = 3.50
	
	music = AudioStreamPlayer.new()
	music.stream = music_stream
	music.autoplay = true
	music.bus = &"MUSIC"
	
	sfx = AudioStreamPlayer.new()
	sfx.autoplay = false
	sfx.bus = &"SFX"
	
	add_child(music)
	add_child(sfx)





























