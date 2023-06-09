extends Node

const server_host = "http://apaantu.id"
const max_timeout = 10

######################################################################

const player_data_file = "player.data"

@onready var wordData :WordsData = WordsData.new()
@onready var player :PlayerData = PlayerData.new()

@onready var level :int = 1
@onready var word_list :Array = []

@onready var player_hint :int = 5
@onready var player_max_hint :int = 5

func _ready():
	wordData.difficulty = WordsData.kids
	wordData.load_words_data()
	
	player.load_data(player_data_file)
	
	setup_player_api()
	setup_rank_api()
	setup_prize_api()
	setup_regenerate_hp_hint()
	setup_sound()
	
func generate_words():
	word_list.clear()
	
	var list = []
	var count = 0
	
	var words_count :int = 5
	var words_length :int = 5
	
	var input = 0
	while (input < level and level > 1):
		input += 10;
		words_count += 2
		words_length += 1
	
	words_count = clamp(words_count, 1, 25)
	words_length = clamp(words_length, 5, 10)
	
	while count < words_count:
		randomize()
		var words :Array = wordData.dictionaries[wordData.dictionaries.keys().pick_random()]
		var word = words.pick_random()
		if len(word) > words_length:
			continue
			
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
var regenerate_reward_hp :RegenerateItemHandler
var regenerate_reward_hint :RegenerateItemHandler

func setup_regenerate_hp_hint():
	current_time = preload("res://assets/current_time/current_time.tscn").instantiate()
	current_time.current_time.connect(_current_time_ready)
	current_time.error.connect(_current_time_error)
	
	var scene = preload("res://assets/regenerate_item_handler/regenerate_item_handler.tscn")
	
	regenerate_hp = scene.instantiate()
	regenerate_hp.item_name = "hp"
	regenerate_hp.cooldown = 1800 # 30 minute
	regenerate_hp.item_count = 5
	regenerate_hp.item_max = 5
	regenerate_hp.on_save.connect(_regenerate_hp_on_save)
	
	regenerate_reward_hp = scene.instantiate()
	regenerate_reward_hp.item_name = "free_hp_reward_ads"
	regenerate_reward_hp.cooldown = 300 # 5 minute
	regenerate_reward_hp.item_count = 1
	regenerate_reward_hp.item_max = 1
	
	regenerate_reward_hint = scene.instantiate()
	regenerate_reward_hint.item_name = "free_hint_reward_ads"
	regenerate_reward_hint.cooldown = 300 # 5 minute
	regenerate_reward_hint.item_count = 1
	regenerate_reward_hint.item_max = 1
	
	add_child(current_time)
	add_child(regenerate_hp)
	add_child(regenerate_reward_hp)
	add_child(regenerate_reward_hint)
	
func _current_time_ready(_current_time :Dictionary):
	# get online progress
	var regenerate_hp_progress :Array = []
	
	if not player.player_id.is_empty():
		player_api.request_one_player(player.player_id)
		var result :Array = await player_api.get_one
		if result[0]:
			var _player :PlayerApi.Player = result[1]
			var _json :Dictionary = JSON.parse_string(_player.save_data_json)
			
			if _json != null:
				if _json.has("regenerate_hp_progress"):
					regenerate_hp_progress = _json["regenerate_hp_progress"] as Array
					
#				if _json.has("player_hp"):
#					regenerate_hp.item_count = _json["player_hp"] as int
					
				if _json.has("player_hint"):
					player_hint = _json["player_hint"] as int
					
				if _json.has("level"):
					level = _json["level"] as int
					generate_words()
				
	regenerate_hp.run_regenerating(_current_time, regenerate_hp_progress)
	regenerate_reward_hp.run_regenerating(_current_time)
	regenerate_reward_hint.run_regenerating(_current_time)
	emit_signal("setup_regenerate_complete", false)
	
func _regenerate_hp_on_save(_datas :Array):
	update_player_data_api()
	
func _current_time_error(_msg :String):
	emit_signal("setup_regenerate_complete", true)
	
######################################################################
# ranks api
var rank_api :RanksApi

func setup_rank_api():
	rank_api = preload("res://apis/ranks_api/ranks_api.tscn").instantiate()
	rank_api.max_timeout = max_timeout
	rank_api.server_host = server_host
	add_child(rank_api)
	
######################################################################
# player api
var player_api :PlayerApi

func setup_player_api():
	player_api = preload("res://apis/player_api/player_api.tscn").instantiate()
	player_api.max_timeout = max_timeout
	player_api.server_host = server_host
	add_child(player_api)
	
func add_player_data_api() -> bool:
	var _empty_save_data_json :String = JSON.stringify({
		"regenerate_hp_progress" : [],
		#"player_hp" : regenerate_hp.item_max,
		"player_hint" : player_max_hint,
		"level" : level,
	})
	var _player :Dictionary = {
		"id": 0,
		"player_id": player.player_id,
		"player_name": player.player_name,
		"player_email": player.player_email,
		"player_avatar": player.player_avatar,
		"save_data_json": _empty_save_data_json
	}
	player_api.request_add_player(PlayerApi.Player.new(_player))
	var ok :bool = await player_api.add
	return ok
	
func update_player_data_api():
	var _save_data_json :String = JSON.stringify({
		"regenerate_hp_progress" : regenerate_hp.get_save_data(),
		#"player_hp" : regenerate_hp.item_count,
		"player_hint" : player_hint,
		"level" : level,
	})
	var _player :Dictionary = {
		"id": 0,
		"player_id": player.player_id,
		"player_name": player.player_name,
		"player_email": player.player_email,
		"player_avatar": player.player_avatar,
		"save_data_json": _save_data_json
	}
	player_api.request_update_player(PlayerApi.Player.new(_player))
	
######################################################################
# prize api
var prize_api :PrizeApi

func setup_prize_api():
	prize_api = preload("res://apis/prize_api/prize_api.tscn").instantiate()
	prize_api.server_host = server_host
	prize_api.max_timeout = max_timeout
	add_child(prize_api)
	
######################################################################

@onready var image_cache :Dictionary = {}

func get_avatar_image(_node :Node, player_id, player_avatar :String) -> ImageTexture:
	if player_avatar.is_empty():
		return null
		
	if Global.image_cache.has(player_id):
		return image_cache[player_id]
		
	var http_request :HTTPRequest = HTTPRequest.new()
	_node.add_child(http_request)
	
	var http_error = http_request.request(player_avatar)
	if http_error != OK:
		http_request.queue_free()
		return null
		
	var result :Array = await http_request.request_completed
	if result[0] != HTTPRequest.RESULT_SUCCESS:
		return null
		
	http_request.queue_free()
	
	var body :PackedByteArray = result[3]
	if body.is_empty():
		return null
		
	var img = _check_image_format(body)
	if img == null:
		return null
		
	image_cache[player_id] = ImageTexture.create_from_image(img)
	return image_cache[player_id]
	
func _check_image_format(body :PackedByteArray) -> Image:
	var img = Image.new()
	
	var image_error = img.load_jpg_from_buffer(body)
	if image_error == OK:
		return img
		
	image_error = img.load_png_from_buffer(body)
	if image_error == OK:
		return img
		
	image_error = img.load_bmp_from_buffer(body)
	if image_error == OK:
		return img
		
	return null
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





























