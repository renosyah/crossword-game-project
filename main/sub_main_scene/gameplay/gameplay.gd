extends Control

signal back_press

const crossword_lib = preload("res://addons/crossword_gen_remake/crossword_gen_remake.gd")

const word_tile = preload("res://entity/word_tile/word_tile.tscn")
const word_input = preload("res://entity/word_input/word_input.tscn")
const word_output = preload("res://entity/word_output/word_output.tscn")

@onready var grid_container = $VBoxContainer/HBoxContainer/GridContainer
@onready var grid = $VBoxContainer/HBoxContainer/GridContainer/grid

@onready var grid_input_container = $VBoxContainer/MarginContainer3/VBoxContainer/CenterContainer/grid_input_container
@onready var word_output_container = $VBoxContainer/MarginContainer3/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer2

@onready var clear_word = $VBoxContainer/MarginContainer3/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/clear_word
@onready var timer_delay = $TimerDelay

var util = Utils.new()
var crossword :crossword_lib.Crossword
var crossword_size :int
var output_sets: Array = []
var max_row_grid = 5
var solved_tiles :Array = []

var default_size :Vector2 = Vector2(50, 50)
var grid_container_size :Vector2
var trimed_crossword :Dictionary

func generate_puzzle():
	solved_tiles.clear()
	_on_clear_word_pressed()
	
	crossword = crossword_lib.Crossword.new(24, 24, '', 5000, Global.word_list)
	crossword.compute_crossword(0)
	
	trimed_crossword = util.trim(crossword.rows, crossword.grid)
	
	await get_tree().process_frame
	grid_container_size = grid_container.size
	
	_calculate_tile_size()
	_build_crossword_grid()
	_display_clue()
	
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
				
			#display_word_founded(word)
			Global.word_list_founded.append(word)
			#_check_if_solved()
			return
			
	# not found
	#player_hurt()
	
func _on_back_button_pressed():
	emit_signal("back_press")

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
	
func _on_clear_word_pressed():
	clear_word.visible = false
	_clear_output()
	output_sets.clear()
	
	
