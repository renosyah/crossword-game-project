extends Control

signal rank
signal dictionary
signal add_to_dictionary(word)
signal back_press(is_from_rank_menu, is_from_list_menu)

const crossword_lib = preload("res://addons/crossword_gen_remake/crossword_gen_remake.gd")

const word_tile = preload("res://entity/word_tile/word_tile.tscn")
const word_input = preload("res://entity/word_input/word_input.tscn")
const word_output = preload("res://entity/word_output/word_output.tscn")

@onready var sfx = $AudioStreamPlayer

@onready var level = $VBoxContainer/HBoxContainer2/level
@onready var rank_label = $rank_button/MarginContainer/HBoxContainer/VBoxContainer/rank_label
@onready var list_label = $VBoxContainer/MarginContainer4/Control/Control/gameplay_helper/list_button/VBoxContainer/list_label
@onready var hint_label = $VBoxContainer/MarginContainer4/Control/Control/gameplay_helper/HBoxContainer/hint_button/VBoxContainer/hint_label
@onready var check_label = $VBoxContainer/Control/MarginContainer3/VBoxContainer/HBoxContainer/check_word/MarginContainer4/check_label
@onready var chance_left = $VBoxContainer/MarginContainer4/Control/Control2/VBoxContainer/chance_left

@onready var grid_container = $VBoxContainer/HBoxContainer/GridContainer
@onready var grid = $VBoxContainer/HBoxContainer/GridContainer/grid

@onready var grid_input_container = $VBoxContainer/Control/MarginContainer3/VBoxContainer/CenterContainer/grid_input_container
@onready var word_output_container = $VBoxContainer/Control/MarginContainer3/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer2

@onready var menu_input_container = $VBoxContainer/Control
@onready var menu_input = $VBoxContainer/Control/MarginContainer3

@onready var hit_point_display = $VBoxContainer/MarginContainer4/Control/Control2/VBoxContainer/HBoxContainer/hit_point_display
@onready var hint_left = $VBoxContainer/MarginContainer4/Control/Control/gameplay_helper/HBoxContainer/hint_button/VBoxContainer/hint_left
@onready var list_button = $VBoxContainer/MarginContainer4/Control/Control/gameplay_helper/list_button
@onready var add_more_hp = $VBoxContainer/MarginContainer4/Control/Control2/VBoxContainer/HBoxContainer/add_more_hp
@onready var add_more_hint = $VBoxContainer/MarginContainer4/Control/Control/gameplay_helper/HBoxContainer/add_more_hint

@onready var clear_word = $VBoxContainer/Control/MarginContainer3/VBoxContainer/HBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/clear_word
@onready var timer_delay = $TimerDelay

@onready var button_rank_container = $rank_button/MarginContainer
@onready var gameplay_helper = $VBoxContainer/MarginContainer4/Control/Control/gameplay_helper
@onready var margin_right = $VBoxContainer/HBoxContainer/MarginContainer2

@onready var panel_reward = $panelReward
@onready var animation_player = $AnimationPlayer

@onready var timer_countdown = $timer_countdown
@onready var simple_panel_message = $simple_panel_message

var util = Utils.new()
var crossword :crossword_lib.Crossword
var crossword_size :int
var output_sets: Array = []
var input_sets :Array = []
var max_row_grid = 6
var max_output_set_size = 12
var solved_tiles :Array = []

var default_size :Vector2 = Vector2(50, 50)
var grid_container_size :Vector2
var reward_for :String

var trimed_crossword :Dictionary
var trimed_crossword_row_count :int
var trimed_crossword_col_count :int
var crossword_displayed_tiles :Dictionary
var current_word_list :Array

func _ready():
	rank_label.text = tr("RANK")
	list_label.text = tr("DICTIONARY")
	hint_label.text = tr("HINT")
	check_label.text = tr("CHECK")
	chance_left.text = tr("CHANCE_LEFT")
	
	add_more_hp.set_enable(false)
	add_more_hint.set_enable(false)
	
	add_more_hint.update_progress(0, 1)
	add_more_hp.update_progress(0, 1)
	
	list_button.pivot_offset = list_button.size / 2
	
	Admob.interstitial_failed_to_show.connect(_interstitial_closed)
	Admob.interstitial_closed.connect(_interstitial_closed)
	
	Admob.rewarded_ad_loaded.connect(_rewarded_ad_loaded)
	Admob.rewarded_ad_failed_to_show.connect(_rewarded_closed)
	Admob.rewarded_ad_closed.connect(_rewarded_closed)
	Admob.user_earned_rewarded.connect(_player_earned_rewarded)
	
	Global.regenerate_hp.regenerate_complete.connect(_regenerate_hp_complete)
	Global.regenerate_reward_hint.one_second_pass.connect(_regenerate_reward_hint_on_tick)
	Global.regenerate_reward_hp.one_second_pass.connect(_regenerate_reward_hp_on_tick)
	
	Global.rank_api.rank_added.connect(_on_rank_added)

func back_to_gameplay():
	animation_player.play_backwards("to_rank")

func generate_puzzle():
	gameplay_helper.custom_minimum_size.x = button_rank_container.size.x
	margin_right.custom_minimum_size.x = button_rank_container.size.x
	
	level.text = "%s %s" % [tr("LEVEL") ,Global.level]
	hit_point_display.hp = Global.regenerate_hp.item_count
	hit_point_display.max_hp = Global.regenerate_hp.item_max
	hit_point_display.display_hp()
	
	hint_left.text = str(Global.player_hint)
	
	animation_player.play("RESET")
	await animation_player.animation_finished
	
	solved_tiles.clear()
	_on_clear_word_pressed()
	
	_load_crossword_progress()
	
	if not _is_progress_exist():
		crossword = crossword_lib.Crossword.new(64, 64, '', 5000, Global.word_list)
		crossword.compute_crossword(0)
		crossword.display()
		
		# to make sure same generate display as before
		Global.word_list.clear()
		current_word_list = crossword.current_word_list_to_arr_of_dict()
		
		for word in current_word_list:
			Global.word_list.append([word.word, "clue"])
		
		trimed_crossword = util.trim(crossword.rows, crossword.grid)
		trimed_crossword_row_count = util.rows
		trimed_crossword_col_count = util.cols
		
		_save_crossword_progress()
	
	_display_input_tile()
	
	await get_tree().process_frame
	menu_input_container.custom_minimum_size = menu_input.size
	
	await get_tree().process_frame
	grid_container_size = grid_container.size
	
	_calculate_tile_size()
	_build_crossword_grid()
	_display_clue()
	
	animation_player.play("show_puzzle")
	
	if not Admob.get_is_rewarded_loaded():
		Admob.load_rewarded()
		
	else:
		_rewarded_ad_loaded()
		
	# load interstitial ads if world list is more than one
	if not Admob.get_is_interstitial_loaded() and Global.word_list.size() > 1:
		Admob.load_interstitial()
		
	if Admob.get_is_banner_loaded():
		Admob.show_banner()
		
	# RULE REVISION
	# hide timer
	timer_countdown.visible = false
	
	# RULE REVISION
	# if player reach more than lvl 1000
	# timer apear, if end, player lose
	if Global.level >= 1000:
		timer_countdown.visible = true
		timer_countdown.wait_time = 300
		timer_countdown.start()
		
	# show panel
	# new rule if player reach lvl 100
	if Global.level == 1000:
		simple_panel_message.title = tr("FINAL_BOSS_TITLE")
		simple_panel_message.message = tr("FINAL_BOSS_DESCRIPTION")
		simple_panel_message.show_panel()
		
func _display_input_tile():
	var characters = []
	for key in trimed_crossword.keys():
		var data :String = trimed_crossword[key]
		if not data.is_empty():
			characters.append(data)
			
	randomize()
	characters.shuffle()
	
	_set_input_character(characters)
	
func _calculate_tile_size():
	default_size = Vector2(50, 50)
	
	var col_size = trimed_crossword_col_count
	var row_size = trimed_crossword_row_count
	
	var row_x_size = (default_size.x + 8) * row_size
	var col_y_size = (default_size.y + 8) * col_size
	
	var diff = Vector2(row_x_size, col_y_size) - grid_container_size
	if diff.x > 0:
		default_size.x -= abs((default_size.x - diff.x) / row_size)
	if diff.y > 0:
		default_size.y -= abs((default_size.y - diff.y) / col_size)
		
	var _min = min(default_size.x, default_size.y)
	default_size = Vector2(_min, _min).clamp(Vector2(15,15), Vector2(50, 50))
	
func _build_crossword_grid():
	for i in grid.get_children():
		grid.remove_child(i)
		i.queue_free()
		
	grid.columns = trimed_crossword_row_count
	
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
	input_sets.clear()
	
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
		input_sets.append(input)
		
		if rows.get_child_count() > max_row_grid:
			rows = HBoxContainer.new()
			rows.alignment = BoxContainer.ALIGNMENT_CENTER
			grid_input_container.add_child(rows)
	
func _on_input_press(button :WordInput, c :String):
	if output_sets.size() > max_output_set_size:
		return
		
	sfx.stream = preload("res://assets/sound/typing.wav")
	sfx.play()
		
	if button.is_pressed:
		output_sets.append(c)
		
	else:
		output_sets.erase(c)
		
	_clear_output()
		
	for i in output_sets:
		var output = word_output.instantiate()
		output.data = i
		word_output_container.add_child(output)
		
	clear_word.visible = not output_sets.is_empty()
	
func _clear_output():
	for i in word_output_container.get_children():
		word_output_container.remove_child(i)
		i.queue_free()
		
func _create_tile_id(row :int, col :int):
	return"{row}-{column}".format({"row":row,"column":col})
	
func _display_clue():
	if _is_displayed_tiles_exist():
		_display_clue_from_last_progress()
	
	else:
		_display_clue_new_progress()
		
		# RULE REVISION
		# if player reach more than lvl 50
		# no starter hint will be display
		if Global.level < 50:
			_save_crossword_progress()
		
func _display_clue_from_last_progress():
	for key in crossword_displayed_tiles.keys():
		var tile :WordTile = get_node_or_null(key)
		if is_instance_valid(tile) and crossword_displayed_tiles[key]:
			tile.show_data()
			
func _display_clue_new_progress():
	crossword_displayed_tiles.clear()
	
	for i in current_word_list:
		var row = i.row
		var col = i.col
		var down_across = i.down_across
		
		var count :int = 0
		for c in range(len(i.word)):
			var id = _create_tile_id(row, col)
			var tile :WordTile = _get_tile(id)
			if is_instance_valid(tile):
				var show_data :bool = count % 2 == 0
				if show_data:
					tile.show_data()
					
				crossword_displayed_tiles[tile.get_path()] = show_data
				
			if down_across == "down":
				row += 1
			elif down_across == "across":
				col += 1
				
			count += 1
	
func _is_progress_exist():
	return not current_word_list.is_empty()
	
func _is_displayed_tiles_exist():
	return not crossword_displayed_tiles.is_empty()
	
func _save_crossword_progress():
	var col_row :Dictionary = {
		"row" : trimed_crossword_row_count,
		"col" : trimed_crossword_col_count
	}
	SaveLoad.save("row_col.dat", col_row)
	SaveLoad.save("trimed_crossword.dat", trimed_crossword)
	SaveLoad.save("crossword_displayed_tiles.dat", crossword_displayed_tiles)
	SaveLoad.save("current_word_list.dat", current_word_list)
	
func _load_crossword_progress():
	crossword_displayed_tiles = {}
	var data_1 = SaveLoad.load_save("crossword_displayed_tiles.dat")
	if data_1 != null:
		crossword_displayed_tiles = data_1 as Dictionary
		
	trimed_crossword = {}
	var data_2 = SaveLoad.load_save("trimed_crossword.dat")
	if data_2 != null:
		trimed_crossword = data_2 as Dictionary
		
	var data_3 = SaveLoad.load_save("row_col.dat")
	if data_3 != null:
		trimed_crossword_row_count = data_3["row"] as int
		trimed_crossword_col_count = data_3["col"] as int
		
	current_word_list = []
	var data_4 = SaveLoad.load_save("current_word_list.dat")
	if data_4 != null:
		current_word_list = data_4 as Array
		
func _delete_crossword_progress():
	crossword_displayed_tiles = {}
	trimed_crossword = {}
	current_word_list = []
	
	SaveLoad.delete_save("current_word_list.dat")
	SaveLoad.delete_save("crossword_displayed_tiles.dat")
	SaveLoad.delete_save("trimed_crossword.dat")
	SaveLoad.delete_save("row_col.dat")
	
func _get_tile(id :String):
	for i in grid.get_children():
		if not i is WordTile:
			continue
			
		if i.id == id:
			return i
			
	return null
	
func _find_and_show_word(word :String):
	for i in current_word_list:
		if i.word == word:
			var row = i.row
			var col = i.col
			var down_across = i.down_across
			
			var _solved_tile :Array = []
			var _animated_items :Array = []
			
			for c in range(len(word)):
				var id = _create_tile_id(row, col)
				var tile :WordTile = _get_tile(id)
				if is_instance_valid(tile) and not solved_tiles.has(tile.id):
					var item_origin = word_output_container.get_child(c)
					var item :WordOutput = item_origin.duplicate()
					item.top_level = true
					item.position = item_origin.global_position
					add_child(item)
					_animated_items.append(item)
					_solved_tile.append(tile)
					
					solved_tiles.append(tile.id)
					
				if down_across == "down":
					row += 1
				elif down_across == "across":
					col += 1
					
			_froze_input_word_buttons()
			_on_clear_word_pressed()
			
			for idx in _solved_tile.size():
				var item :WordOutput = _animated_items[idx]
				var solved_tile :WordTile = _solved_tile[idx]
				
				item.visible = true
				_run_animated_solved(item, solved_tile)
				
				timer_delay.start()
				await timer_delay.timeout
				
			return
			
	# run to dictionary
	if Global.wordData.is_in_dictionary(word):
		var _animated_items :Array = []
		
		for c in range(len(word)):
			var item_origin = word_output_container.get_child(c)
			var item :WordOutput = item_origin.duplicate()
			item.top_level = true
			item.position = item_origin.global_position
			add_child(item)
			_animated_items.append(item)
			
		_on_clear_word_pressed()
		
		for item in _animated_items:
			item.visible = true
			_run_animated_enter_dictionary(item)
			
			timer_delay.start()
			await timer_delay.timeout
			
		emit_signal("add_to_dictionary", word)
		return
		
	# not found
	_on_clear_word_pressed()
	_player_hurt()
	
func _froze_input_word_buttons():
	# cannot use same character
	# disable it tile
	for i in input_sets:
		var input :WordInput = i
		if input.is_pressed:
			input.is_enable = false
			input.check_is_enable()
	
func _run_animated_solved(item :WordOutput, solved_tile :WordTile):
	item.speed = 935
	item.animated(solved_tile.global_position)
	await item.reach
	item.queue_free()
	solved_tile.solved()
	_check_if_solved()
	
var _tween_button_list :Tween
	
func _run_animated_enter_dictionary( item :WordOutput):
	item.speed = 935
	item.animated(list_button.global_position)
	await item.reach
	item.queue_free()
	
	if _tween_button_list:
		_tween_button_list.kill()
		
	_tween_button_list = create_tween()
	list_button.scale = Vector2.ONE * 1.5
	_tween_button_list.tween_property(list_button, "scale", Vector2.ONE, 0.3)
	
	sfx.stream = preload("res://assets/sound/pop.wav")
	sfx.play()
	
func _player_hurt():
	sfx.stream = preload("res://assets/sound/popout.wav")
	sfx.play()
	
	# hp decrease & regenerate
	Global.regenerate_hp.add_generate_item()
	hit_point_display.pop_hp()
	
	if Global.regenerate_hp.item_count == 0:
		var is_aggree :bool = await _offer_watch_ads_to_get_hp()
		if is_aggree:
			return
			
		await get_tree().create_timer(0.8).timeout
		_player_lose()
		
func _offer_watch_ads_to_get_hp() -> bool:
	var _reward_is_loaded = Admob.get_is_rewarded_loaded()
	var _has_reward_quota_ok = Global.regenerate_reward_hp.item_count > 0
	var _is_not_web_app = "Web" != OS.get_name()
	
	if _has_reward_quota_ok and _is_not_web_app and _reward_is_loaded:
		panel_reward.title = tr("LOW_OF_CHANCE")
		panel_reward.description = tr("LOW_OF_CHANCE_DESC")
		panel_reward.button_title = tr("GET_FREE_CHANCE")
		panel_reward.show_panel()
		
		# wait
		var is_aggree :bool = await panel_reward.watch_ads
		if is_aggree:
			Global.regenerate_reward_hp.add_generate_item()
			_watch_reward_ads("hp")
			return true
			
	return false
	
func _offer_watch_ads_to_get_hint() -> bool:
	var _is_hint_not_max = Global.player_hint < Global.player_max_hint
	var _reward_is_loaded = Admob.get_is_rewarded_loaded()
	var _has_reward_quota_ok = Global.regenerate_reward_hint.item_count > 0
	var _is_not_web_app = "Web" != OS.get_name()
	
	if _has_reward_quota_ok and _is_not_web_app and _reward_is_loaded and _is_hint_not_max:
		panel_reward.title = tr("LOW_OF_HINT")
		panel_reward.description = tr("LOW_OF_CHANCE_HINT")
		panel_reward.button_title = tr("GET_FREE_HINT")
		panel_reward.show_panel()
		
		# wait
		var is_aggree :bool = await panel_reward.watch_ads
		if is_aggree:
			Global.regenerate_reward_hint.add_generate_item()
			_watch_reward_ads("hint")
			return true
			
	return false
	
# RULE REVISION
# if player hp is 0, and player click
# add hp more hp, display ads reward offer
func _on_add_more_hp_pressed():
	_offer_watch_ads_to_get_hp()
	
func _on_add_more_hint_pressed():
	_offer_watch_ads_to_get_hint()
	
func _watch_reward_ads(_for :String):
	reward_for = _for
	
	if Admob.get_is_rewarded_loaded():
		# hide banner!
		# prevent from overlapping
		# with rewarded
		Admob.hide_banner()
		Admob.show_rewarded()
		return
		
	_rewarded_closed()
	
# RULE REVISION
# if rewards ads is ready
# show offer add hp or hint
# by watch reward video ads
func _rewarded_ad_loaded():
	if Global.regenerate_hp.item_count == 0:
		var _has_reward_quota_ok :bool = Global.regenerate_reward_hp.item_count > 0
		add_more_hp.set_enable(_has_reward_quota_ok)
		
	if Global.player_hint < Global.player_max_hint:
		var _has_reward_quota_ok :bool = Global.regenerate_reward_hint.item_count > 0
		add_more_hint.set_enable(_has_reward_quota_ok)
	
func _rewarded_closed():
	if Admob.get_is_banner_loaded():
		Admob.show_banner()
		
	if not Admob.get_is_rewarded_loaded():
		Admob.load_rewarded()
		
	add_more_hp.set_enable(false)
	add_more_hint.set_enable(false)
	
func _player_earned_rewarded(_reward_type :String, _amount:int):
	# add 1 more hp
	if reward_for == "hp":
		Global.regenerate_hp.remove_generate_item(1)
		_regenerate_hp_complete()
		
	# add 2 more hint
	if reward_for == "hint":
		Global.player_hint += 2
		hint_left.text = str(Global.player_hint)
	
	Global.update_player_data_api()
	
	
func _player_lose():
	# RULE REVISION
	# if player reach more than lvl 1000
	# if player lose, drop 50 lvl
	if Global.level >= 1000:
		Global.level -= 50
		_delete_crossword_progress()
		Global.generate_words()
		
		# show panel
		# why player lose 50 lvl
		simple_panel_message.title = tr("DROP_LEVEL_TITLE")
		simple_panel_message.message = tr("DROP_LEVEL_DESCRIPTION")
		simple_panel_message.show_panel()
		
		# reset puzzle
		
		generate_puzzle()
		return
	
	#Global.reset_player()
	_delete_crossword_progress()
	Global.generate_words()
	
	_on_back_button_pressed()
	
func _submit_rank():
	var _rank = RanksApi.Rank.new({
		"id": 0,
		"player_id": Global.player.player_id,
		"player_name": Global.player.player_name,
		"player_email": Global.player.player_email,
		"player_avatar" : Global.player.player_avatar,
		"rank_level" : Global.level,
	})
	Global.rank_api.request_add_ranks(_rank)
	await Global.rank_api.rank_added
	
func _on_rank_added(_ok :bool):
	pass
	
func _on_timer_countdown_timeout():
	_player_lose()
	
func _check_if_solved():
	for i in grid.get_children():
		if not i is WordTile:
			continue
			
		if not i.is_solved:
			return
			
	_show_solved()
	
func _show_solved():
	_submit_rank()
	
	sfx.stream = preload("res://assets/sound/completed.wav")
	sfx.play()
	
	# RULE REVISION
	# stop timer
	timer_countdown.stop()
	
	await get_tree().create_timer(1.5).timeout
	
	Global.level += 1
	Global.generate_words()
	
	Global.update_player_data_api()
	
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
	_delete_crossword_progress()
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
			var item :WordOutput = word_output.instantiate()
			item.data = i.data
			item.top_level = true
			item.position = hint_left.global_position
			add_child(item)
			item.animated(i.global_position)
			await item.reach
			item.queue_free()
			i.show_data()
			
			sfx.stream = preload("res://assets/sound/pop.wav")
			sfx.play()
			
			crossword_displayed_tiles[i.get_path()] = true
			_save_crossword_progress()
			return
	
func _on_check_word_pressed():
	var _word :String = ""
	for i in output_sets:
		_word += i
		
	if _word.is_empty():
		return
		
	_find_and_show_word(_word)

func _on_hint_button_pressed():
	if Global.player_hint < Global.player_max_hint:
		var _has_reward_quota_ok :bool = Global.regenerate_reward_hint.item_count > 0
		add_more_hint.set_enable(Admob.get_is_rewarded_loaded() and _has_reward_quota_ok)
		
	if Global.player_hint == 0:
		_offer_watch_ads_to_get_hint()
		return
		
	sfx.stream = preload("res://assets/sound/pop_hint.wav")
	sfx.play()
		
	# hint decrease & regenerate
	Global.player_hint -= 1
	hint_left.text = str(Global.player_hint)
	
	# update hint save online
	Global.update_player_data_api()
	
	_display_hint()
	_on_clear_word_pressed()
	
func _on_clear_word_pressed():
	clear_word.visible = false
	_clear_output()
	output_sets.clear()
	
	for i in input_sets:
		var input :WordInput = i
		if input.is_enable:
			input.is_pressed = false
			input.check_is_pressed() 
	
func _regenerate_hp_complete():
	hit_point_display.hp = Global.regenerate_hp.item_count
	hit_point_display.max_hp = Global.regenerate_hp.item_max
	hit_point_display.display_hp()
	
func _regenerate_reward_hint_on_tick():
	var items :Array = Global.regenerate_reward_hint.regenerating_items
	var max_time :int = Global.regenerate_reward_hint.cooldown
	
	if items.is_empty():
		return
		
	var item :RegenerateItemHandler.regenerateItem = items.back()
	add_more_hint.update_progress(item.get_remaining(), max_time)
	
func _regenerate_reward_hp_on_tick():
	var items :Array = Global.regenerate_reward_hp.regenerating_items
	var max_time :int = Global.regenerate_reward_hp.cooldown
	
	if items.is_empty():
		return
		
	var item :RegenerateItemHandler.regenerateItem = items.back()
	add_more_hp.update_progress(item.get_remaining(), max_time)
	
	
func _on_back_button_pressed():
	# RULE REVISION
	# stop timer
	timer_countdown.stop()
	
	animation_player.play_backwards("show_puzzle")
	await animation_player.animation_finished
	emit_signal("back_press")
	
func _on_rank_button_pressed():
	animation_player.play("to_rank")
	await animation_player.animation_finished
	emit_signal("rank")
	
func _on_list_button_pressed():
	animation_player.play("to_rank")
	await animation_player.animation_finished
	emit_signal("dictionary")


