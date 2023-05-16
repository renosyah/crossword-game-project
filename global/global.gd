extends Node
######################################################################

@onready var wordData = WordsData.new()

@onready var player_id :String = ""
@onready var player_name :String = ""

@onready var player_hint :int = 10
@onready var player_max_hint :int = 10
@onready var player_hp :int = 5
@onready var player_max_hp :int = 5
@onready var player_score :int = 0

@onready var level :int = 1
@onready var words_count :int = 5
@onready var word_list :Array = []
@onready var word_list_founded :Array= []

func _ready():
	wordData.difficulty = wordData.easy
	wordData.load_words_data()
	
func reset_player():
	level = 1
	player_hint = player_max_hint
	player_hp = player_max_hp
	player_score = 0
	
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

@onready var scores_limit :int = 20
@onready var scores :Array = load_scores()

func load_scores() -> Array:
	var _scores = SaveLoad.load_save("scores.dat")
	if _scores == null:
		return []
		
	_scores.sort_custom(Callable(ScoreSorter, "sort"))
	return _scores
	
func get_scores() -> Array:
	var _scores :Array = []
	
	for i in scores:
		var score = ScoreData.new()
		score.from_dictionary(i)
		_scores.append(score)
	
	return _scores
	
func save_score():
	var score = ScoreData.new()
	score.level = level
	score.score = player_score
	
	scores.append(score.to_dictionary())
	
	if scores.size() > scores_limit:
		scores.pop_back()
		
	scores.sort_custom(Callable(ScoreSorter, "sort"))
	SaveLoad.save("scores.dat", scores)
	
class ScoreSorter:
	static func sort(a, b):
		if a["score"] > b["score"]:
			return true
		return false









