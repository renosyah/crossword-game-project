extends Control

const crossword_lib = preload("res://addons/crossword_gen_remake/crossword_gen_remake.gd")
const word_tile = preload("res://entity/word_tile/word_tile.tscn")

const word_input = preload("res://entity/word_input/word_input.tscn")
const word_output = preload("res://entity/word_output/word_output.tscn")

const pop_textures = [
	preload("res://assets/poping/star.png"),
	preload("res://assets/poping/star.png")
]
const poping = preload("res://assets/poping/poping.tscn")

@onready var control = $CanvasLayer/Control

@onready var label_level = $CanvasLayer/Control/safearea/VBoxContainer/MarginContainer3/label_level
@onready var ui_hp = $CanvasLayer/Control/safearea/VBoxContainer/MarginContainer3/ui_hp

@onready var grid_container = $CanvasLayer/Control/safearea/VBoxContainer/HBoxContainer/GridContainer
@onready var grid = $CanvasLayer/Control/safearea/VBoxContainer/HBoxContainer/GridContainer/grid

@onready var grid_input_container = $CanvasLayer/Control/safearea/VBoxContainer/MarginContainer2/VBoxContainer/CenterContainer/grid_input_container
@onready var word_output_container = $CanvasLayer/Control/safearea/VBoxContainer/MarginContainer2/VBoxContainer/MarginContainer3/HBoxContainer/word_output_container

@onready var hurt = $CanvasLayer/Control/SafeArea/hurt
@onready var result = $CanvasLayer/Control/SafeArea/VBoxContainer/result
@onready var label_score = $CanvasLayer/Control/safearea/VBoxContainer/HBoxContainer2/label_score

@onready var timer = $Timer
@onready var failed = $CanvasLayer/Control/failed
@onready var score = $CanvasLayer/Control/score
@onready var timer_delay = $TimerDelay

@onready var hint = $CanvasLayer/Control/safearea/VBoxContainer/MarginContainer2/VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/hint

var util = Utils.new()
var crossword :crossword_lib.Crossword
var crossword_size :int
var output_sets: Array = []
var max_row_grid = 5
var solved_tiles :Array = []

var default_size :Vector2 = Vector2(50, 50)
var grid_container_size :Vector2
var trimed_crossword :Dictionary

func _ready():
	ui_hp.hp = Global.player_hp
	ui_hp.max_hp = Global.player_max_hp
	ui_hp.display()
	
	label_score.text = str(Global.player_score)
	
	hint.text = "Hint ({ht})".format({"ht" : Global.player_hint})
	hint.disabled = Global.player_hint < 1
		
	label_level.text = "Level {lvl}".format({"lvl" : Global.level})
	
	failed.visible = false
	score.visible = false
	
	crossword = crossword_lib.Crossword.new(24, 24, '', 5000, Global.word_list)
	crossword.compute_crossword(0)
	
	trimed_crossword = util.trim(crossword.rows, crossword.grid)
	
	await get_tree().process_frame
	grid_container = grid_container.size
	
	_calculate_tile_size()
	_build_crossword_grid()
	_display_clue()
	
	# test interstitial
	Admob.interstitial_closed.connect(_interstitial_finished)
	Admob.interstitial_failed_to_show.connect(_interstitial_finished)
	
	if not Admob.get_is_interstitial_loaded():
		Admob.load_interstitial()
		
	# test admob banner
	if Admob.get_is_banner_loaded():
		Admob.show_banner()
	else:
		Admob.load_banner()
		
		
func _calculate_tile_size():
	var trimed :Dictionary = util.trim(crossword.rows, crossword.grid)
	var row_x_size = (default_size.x + 8) * util.rows
	var col_y_size = (default_size.y + 8) * util.cols
	
	var diff = Vector2(row_x_size, col_y_size) - grid_container
	if diff.x > 0:
		default_size.x -= abs((default_size.x - diff.x) / util.rows)
	if diff.y > 0:
		default_size.y -= abs((default_size.y - diff.y) / util.cols)
		
	var min = min(default_size.x, default_size.y)
	default_size = Vector2(min, min).clamp(Vector2(15,15), Vector2(50, 50))
		
	#print(util.rows,":",util.cols, " container : ", grid_container, " diff : ", diff, " ajust size : ", default_size)
	
func _build_crossword_grid():
	#print("1. grid  : ", grid.size, " container : ", grid_container, " tile size : ", default_size)
	for i in grid.get_children():
		grid.remove_child(i)
		i.queue_free()
		
	var characters = []
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
				
			if not characters.has(tile.data):
				characters.append(tile.data)
		else:
			grid.add_child(Control.new())
			
	randomize()
	characters.shuffle()
	
	_set_input_character(characters)
	#await grid.item_rect_changed
	#print("2. grid  : ", grid.size, "container : ", grid_container, " tile size : ", default_size)
	
func _create_tile_id(row :int, col :int):
	return"{row}-{column}".format({"row":row,"column":col})
	
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
				
					display_pop(tile.global_position + tile.size / 2)
				
			display_word_founded(word)
			Global.word_list_founded.append(word)
			_check_if_solved()
			return
			
	# not found
	player_hurt()
	
func _check_if_solved():
	for i in grid.get_children():
		if not i is WordTile:
			continue
			
		if not i.is_show:
			return
			
	_show_solved()
	
func _get_tile(id :String):
	for i in grid.get_children():
		if not i is WordTile:
			continue
			
		if i.id == id:
			return i
			
	return null
	
func _on_input_press(c :String):
	if output_sets.size() > 10:
		return
		
	output_sets.append(c)
	_clear_output()
		
	for i in output_sets:
		var output = word_output.instantiate()
		output.data = i
		word_output_container.add_child(output)
	
func _clear_output():
	for i in word_output_container.get_children():
		word_output_container.remove_child(i)
		i.queue_free()
	
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
		
	_interstitial_finished()
	
func _interstitial_finished():
	get_tree().reload_current_scene()
	
func _on_clear_pressed():
	output_sets.clear()
	_clear_output()
	
func _on_find_pressed():
	var word :String
	for i in output_sets:
		word += i
		
	_on_clear_pressed()
	
	if word.is_empty():
		return
		
	if Global.word_list_founded.has(word):
		return
		
	_find_and_show_word(word)
	
func player_hurt():
	Global.player_hp -= 1
	
	ui_hp.hp = Global.player_hp
	ui_hp.display()
	
	hurt.show_hurt()
	result.show_wrong()
	
	if Global.player_hp < 1:
		failed.visible = true
		Global.save_score()
		return
	
func display_word_founded(word_founded :String):
	Global.player_score += len(word_founded)
	label_score.text = str(Global.player_score)
	result.show_ok()
	
func display_pop(_at :Vector2):
	var pop = poping.instantiate()
	pop.texture = pop_textures[randf_range(0, pop_textures.size())]
	pop.amount = randf_range(2,6)
	pop.color = Color(randf(),randf(),randf(), 1)
	pop.position = _at
	control.add_child(pop)
	pop.pop()
	
func _on_hint_pressed():
	if Global.player_hint < 1:
		return
		
	Global.player_hint -= 1
	hint.disabled = Global.player_hint < 1
		
	hint.text = "Hint ({ht})".format({"ht" : Global.player_hint})
	_display_hint()
	_on_clear_pressed()
	
func _on_score_button_pressed():
	score.visible = true
	score.display_score(Global.get_scores())
	
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")





























