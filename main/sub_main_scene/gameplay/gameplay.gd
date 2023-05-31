extends Control

signal rank
signal back_press(is_from_rank_menu)

const crossword_lib = preload("res://addons/crossword_gen_remake/crossword_gen_remake.gd")

const word_tile = preload("res://entity/word_tile/word_tile.tscn")
const word_input = preload("res://entity/word_input/word_input.tscn")
const word_output = preload("res://entity/word_output/word_output.tscn")

@onready var level = $VBoxContainer/HBoxContainer2/level

@onready var grid_container = $VBoxContainer/HBoxContainer/GridContainer
@onready var grid = $VBoxContainer/HBoxContainer/GridContainer/grid

@onready var grid_input_container = $VBoxContainer/Control/MarginContainer3/VBoxContainer/CenterContainer/grid_input_container
@onready var word_output_container = $VBoxContainer/Control/MarginContainer3/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer2

@onready var menu_input_container = $VBoxContainer/Control
@onready var menu_input = $VBoxContainer/Control/MarginContainer3

@onready var hit_point_display = $VBoxContainer/MarginContainer4/Control/Control2/VBoxContainer/hit_point_display
@onready var hint_left = $VBoxContainer/MarginContainer4/Control/Control/gameplay_helper/hint_button/VBoxContainer/hint_left

@onready var clear_word = $VBoxContainer/Control/MarginContainer3/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/clear_word
@onready var timer_delay = $TimerDelay
@onready var timer = $Timer

var util = Utils.new()
var crossword :crossword_lib.Crossword
var crossword_size :int
var output_sets: Array = []
var max_row_grid = 8
var solved_tiles :Array = []

var default_size :Vector2 = Vector2(50, 50)
var grid_container_size :Vector2
var trimed_crossword :Dictionary

@onready var animation_player = $AnimationPlayer

func _ready():
	Admob.interstitial_failed_to_show.connect(_interstitial_closed)
	Admob.interstitial_closed.connect(_interstitial_closed)

func generate_puzzle():
	level.text = "Level %s" % Global.level
	hit_point_display.hp = Global.player_hp
	hit_point_display.max_hp = Global.player_max_hp
	hit_point_display.display_hp()
	
	animation_player.play("RESET")
	await animation_player.animation_finished
	
	solved_tiles.clear()
	_on_clear_word_pressed()
	
	crossword = crossword_lib.Crossword.new(24, 24, '', 5000, Global.word_list)
	crossword.compute_crossword(0)
	
	# to make sure same generate display as before
	Global.word_list.clear()
	Global.word_list_founded.clear()
	
	for word in crossword.current_word_list:
		Global.word_list.append([word.word, "clue"])
	
	trimed_crossword = util.trim(crossword.rows, crossword.grid)
	
	_display_input_tile()
	
	await get_tree().process_frame
	menu_input_container.custom_minimum_size = menu_input.size
	
	await get_tree().process_frame
	grid_container_size = grid_container.size
	
	_calculate_tile_size()
	_build_crossword_grid()
	_display_clue()
	
	animation_player.play("show_puzzle")
	
	if not Admob.get_is_interstitial_loaded():
		Admob.load_interstitial()
		
	if Admob.get_is_banner_loaded():
		Admob.show_banner()
		
func _display_input_tile():
	var characters = []
	for key in trimed_crossword.keys():
		var data :String = trimed_crossword[key]
		if not data.is_empty() and not characters.has(data):
			characters.append(data)
			
	randomize()
	characters.shuffle()
	
	_set_input_character(characters)
	
func _calculate_tile_size():
	var trimed :Dictionary = util.trim(crossword.rows, crossword.grid)
	var row_x_size = (default_size.x + 8) * util.rows
	var col_y_size = (default_size.y + 8) * util.cols
	
	var diff = Vector2(row_x_size, col_y_size) - grid_container_size
	if diff.x > 0:
		default_size.x -= abs((default_size.x - diff.x) / util.rows)
	if diff.y > 0:
		default_size.y -= abs((default_size.y - diff.y) / util.cols)
		
	var min = min(default_size.x, default_size.y)
	default_size = Vector2(min, min).clamp(Vector2(15,15), Vector2(50, 50))
	
func _build_crossword_grid():
	for i in grid.get_children():
		grid.remove_child(i)
		i.queue_free()
		
	grid.columns = util.rows
	
	for key in trimed_crossword.keys():
		if not trimed_crossword[key].is_empty():
			var id = _create_tile_id(int(key.y) + 1, int(key.x) + 1)
			var tile :WordTile = word_tile.instantiate()
			tile.id = id
			tile.name = id
			tile.data = trimed_crossword[key]
			grid.add_child(tile)
			
			tile.custom_minimum_size = default_size
			tile.tile_size_updated()
			
			if solved_tiles.has(tile.id):
				tile.solved()
		else:
			grid.add_child(Control.new())
			
	
func _set_input_character(characters :Array):
	for i in grid_input_container.get_children():
		grid_input_container.remove_child(i)
		i.queue_free()
		
	var rows :HBoxContainer = HBoxContainer.new()
	rows.alignment = BoxContainer.ALIGNMENT_CENTER
	grid_input_container.add_child(rows)
	
	for c in characters:
		var input = word_input.instantiate()
		input.data = c
		input.connect("on_press", Callable(self, "_on_input_press"))
		rows.add_child(input)
		
		if rows.get_child_count() > max_row_grid:
			rows = HBoxContainer.new()
			rows.alignment = BoxContainer.ALIGNMENT_CENTER
			grid_input_container.add_child(rows)
			
func _on_input_press(c :String):
	if output_sets.size() > 10:
		return
		
	output_sets.append(c)
	_clear_output()
		
	for i in output_sets:
		var output = word_output.instantiate()
		output.data = i
		word_output_container.add_child(output)
		
	clear_word.visible = true
		
func _clear_output():
	for i in word_output_container.get_children():
		word_output_container.remove_child(i)
		i.queue_free()
		
func _create_tile_id(row :int, col :int):
	return"{row}-{column}".format({"row":row,"column":col})
	
func _display_clue():
	for i in crossword.current_word_list:
		var row = i.row
		var col = i.col
		var down_across = i.down_across()
		
		var clue_pass = 0 if randf() > 0.5 else 1
		
		for c in range(len(i.word)):
			var id = _create_tile_id(row, col)
			var tile :WordTile = _get_tile(id)
			if is_instance_valid(tile) and c % 2 == clue_pass:
				tile.show_data()
				
			if down_across == "down":
				row += 1
			elif down_across == "across":
				col += 1
				
func _get_tile(id :String):
	for i in grid.get_children():
		if not i is WordTile:
			continue
			
		if i.id == id:
			return i
			
	return null
	
func _find_and_show_word(word :String):
	for i in crossword.current_word_list:
		if i.word == word:
			var row = i.row
			var col = i.col
			var down_across = i.down_across()
			
			for c in range(len(word)):
				var id = _create_tile_id(row, col)
				var tile :WordTile = _get_tile(id)
				if is_instance_valid(tile) and not solved_tiles.has(tile.id):
					tile.solved()
					solved_tiles.append(tile.id)
					
				if down_across == "down":
					row += 1
				elif down_across == "across":
					col += 1
					
				if is_instance_valid(tile):
					timer_delay.start()
					await timer_delay.timeout
				
			Global.word_list_founded.append(word)
			_check_if_solved()
			return
			
	# not found
	_player_hurt()
	
func _player_hurt():
	Global.player_hp -= 1
	hit_point_display.pop_hp()
	
	if Global.player_hp == 0:
		_player_lose()
		
func _player_lose():
	Global.reset_player()
	Global.generate_words()
	
	animation_player.play_backwards("show_puzzle")
	await animation_player.animation_finished
	_on_back_button_pressed()
	
func _check_if_solved():
	for i in grid.get_children():
		if not i is WordTile:
			continue
			
		if not i.is_solved:
			return
			
	_show_solved()
	
func _show_solved():
	timer.wait_time = 1.3
	timer.start()
	await timer.timeout
	
	Global.level += 1
	Global.generate_words()
	
	if Admob.get_is_interstitial_loaded():
		# hide banner!
		# prevent from overlapping
		# with interstitial
		Admob.hide_banner()
		Admob.show_interstitial()
		return
		
	_interstitial_closed()
	
func _interstitial_closed():
	# reset puzzle
	generate_puzzle()
	
	if Admob.get_is_banner_loaded():
		Admob.show_banner()
	
func _display_hint():
	var rand = grid.get_children().duplicate()
	
	randomize()
	rand.shuffle()
	
	for i in rand:
		if not i is WordTile:
			continue
			
		if not i.is_show:
			i.show_data()
			return
	
func _on_check_word_pressed():
	var word :String
	for i in output_sets:
		word += i
		
	_on_clear_word_pressed()
	
	if word.is_empty():
		return
		
	if Global.word_list_founded.has(word):
		return
		
	_find_and_show_word(word)

func _on_hint_button_pressed():
	if Global.player_hint == 0:
		return
		
	Global.player_hint -= 1
	hint_left.text = str(Global.player_hint)
	_display_hint()
	_on_clear_word_pressed()
	
func _on_clear_word_pressed():
	clear_word.visible = false
	_clear_output()
	output_sets.clear()
	
var _is_on_rank_menu :bool = false
	
func _on_back_button_pressed():
	if _is_on_rank_menu:
		emit_signal("back_press", _is_on_rank_menu)
		
		animation_player.play_backwards("to_rank")
		_is_on_rank_menu = false
		
	else:
		animation_player.play_backwards("show_puzzle")
		await animation_player.animation_finished
		emit_signal("back_press", _is_on_rank_menu)
	
		
func _on_rank_button_pressed():
	_is_on_rank_menu = true
	animation_player.play("to_rank")
	emit_signal("rank")
	




