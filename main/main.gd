extends Control

@onready var animated_background :AnimatedBackground = $CanvasLayer/Control/animated_background
@onready var loading = $CanvasLayer/Control/loading

# audio
@onready var music = Global.music
@onready var sfx = Global.sfx
@onready var click_sound = preload("res://assets/sound/click.wav")

# menu
@onready var login = $CanvasLayer/Control/SafeArea/login
@onready var main_menu = $CanvasLayer/Control/SafeArea/main_menu
@onready var gameplay = $CanvasLayer/Control/SafeArea/gameplay
@onready var rank = $CanvasLayer/Control/SafeArea/rank
@onready var dictionary = $CanvasLayer/Control/SafeArea/dictionary
@onready var error_display = $CanvasLayer/Control/error_display
@onready var prize = $CanvasLayer/Control/SafeArea/prize
@onready var banner = $CanvasLayer/Control/SafeArea/banner

var navigations :Array = []
var has_error :bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	var is_web_app :bool = ["Web"].has(OS.get_name())
	loading.visible = false
	
	_hide_all()
	
	Admob.banner_loaded.connect(_admob_banner_loaded)
	
	# have login session
	if not Global.player.player_id.is_empty():
		loading.visible = true
		
		await _preparing()
		
		if has_error:
			_show_panel_error()
			return
		
		animated_background.set_stage(3)
		loading.visible = false
		_show_main_menu()
		return
		
	if is_web_app:
		OAuth2.check_sign_in_status()
		
	await get_tree().create_timer(1).timeout
	animated_background.set_stage(1)
	login.visible = true
	login.show_icon()
	
	await get_tree().create_timer(2).timeout
	
	animated_background.set_stage(2)
	login.show_login_form()
	
func _preparing():
	# prepare admob, and regenerator
	await _init_admob()
	
	Global.current_time.request_current_time()
	has_error = await Global.setup_regenerate_complete
	
func _on_error_display_retry():
	get_tree().reload_current_scene()
	
func _init_admob():
	Admob.initialize()
	await Admob.initialization_finish
	
	if not Admob.get_is_banner_loaded():
		Admob.load_banner()
		
# Called when the system give event
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			on_back_pressed()
			return
		NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	if navigations.is_empty():
		get_tree().quit()
		return
		
	var back :String = navigations.back()
	match (back):
		"gameplay":
			_on_gameplay_back_press()
		"rank":
			_on_rank_back()
		"prize":
			_on_prize_back()
		"dictionary":
			_on_dictionary_back()
	
	
func _hide_all():
	main_menu.visible = false
	gameplay.visible = false
	login.visible = false
	dictionary.visible = false
	rank.visible = false
	prize.visible = false
	banner.visible = false
	
func _show_panel_error():
	navigations.clear()
	
	error_display.visible = true
	error_display.error_title = tr("NO_INTERNET")
	error_display.error_description = tr("NO_INTERNET_DESCRIPTION")
	error_display.show_error()
	
	loading.visible = false
	_hide_all()
	
#------------------------------ login ------------------------------------#
var _login_with :String

func _on_login_login_completed(_with :String):
	_login_with = _with
	_to_main_menu()
	
func _get_profile():
	if _login_with == "google":
		OAuth2.get_profile_info()
		var result = await OAuth2.profile_info
		if result != null:
			var profile :OAuth2.OAuth2UserInfo = result
			Global.player.player_id = profile.id
			Global.player.player_email = profile.email
			Global.player.player_name = profile.given_name
			Global.player.player_avatar = profile.picture
			Global.player.save_data(Global.player_data_file)
			
			await get_tree().process_frame
			
			# register new player
			await Global.add_player_data_api()
			
	if _login_with == "google_play_service":
		var _player :PlayService.User = login.play_service_player
		Global.player.player_id = _player.id
		Global.player.player_email = _player.email
		Global.player.player_name = _player.displayName
		Global.player.player_avatar = ""
		Global.player.save_data(Global.player_data_file)
		
		await get_tree().process_frame
		
		# register new player
		await Global.add_player_data_api()
		
#------------------------------ main menu ------------------------------------#
func _to_main_menu():
	login.visible = false
	animated_background.set_stage(3, true)
	loading.visible = true
	
	await _get_profile()
	await _preparing()
	
	if has_error:
		_show_panel_error()
		return
		
	animated_background.set_stage(3)
	loading.visible = false
	
	banner.visible = true
	banner.server_host = Global.server_host
	banner.request_banners()
	
	_show_main_menu()
	
func _show_main_menu():
	main_menu.visible = true
	main_menu.show_menu()
	
func _admob_banner_loaded():
	Admob.show_banner()
	
func _on_main_menu_play():
	sfx.stream = click_sound
	sfx.play()
	
	animated_background.set_stage(4)
	navigations.append("gameplay")
	_hide_all()
	
	# RULE REVISION
	# hell puzzle lvl 50
	if Global.level >= 50 and Global.wordData.difficulty != WordsData.hard:
		Global.wordData.difficulty = WordsData.hard
		Global.wordData.load_words_data()
		
	gameplay.visible = true
	gameplay.generate_puzzle()

func _on_main_menu_logout():
	sfx.stream = click_sound
	sfx.play()
	
	loading.visible = true
	OAuth2.sign_out()
	await OAuth2.sign_out_completed
	
	if ["Android"].has(OS.get_name()):
		PlayService.signOut()
		await PlayService.on_sign_out
	
	loading.visible = false
	animated_background.set_stage(3, true)
	await animated_background.stage_finish
	
	# delete all
	Global.player.delete_data(Global.player_data_file)
	SaveLoad.delete_save("current_word_list.dat")
	SaveLoad.delete_save("crossword_progress.dat")
	SaveLoad.delete_save("trimed_crossword.dat")
	SaveLoad.delete_save("row_col.dat")
	
	Global.player = PlayerData.new()
	get_tree().reload_current_scene()
	
func _on_main_menu_rank():
	sfx.stream = click_sound
	sfx.play()
	
	animated_background.set_stage(4)
	navigations.append("rank")
	_hide_all()
	
	rank.visible = true
	rank.show_ranks()
	
#------------------------------ gameplay ------------------------------------#
func _on_gameplay_rank():
	sfx.stream = click_sound
	sfx.play()
	
	animated_background.set_stage(4, true)
	navigations.append("rank")
	_hide_all()
	
	rank.visible = true
	rank.show_ranks()
	
func _on_gameplay_dictionary():
	sfx.stream = click_sound
	sfx.play()
	
	navigations.append("dictionary")
	_hide_all()
	
	dictionary.visible = true
	dictionary.show_dictionary()
	
func _on_gameplay_add_to_dictionary(word :String):
	if dictionary.words.has(word):
		return
		
	dictionary.words.append(word)
	
func _on_gameplay_back_press():
	sfx.stream = click_sound
	sfx.play()
	
	animated_background.set_stage(4, true)
	navigations.pop_back()
	_hide_all()
	
	await get_tree().process_frame
	main_menu.visible = true
	main_menu.show_menu(true)
	
#------------------------------ rank ------------------------------------#
func _on_rank_prize():
	sfx.stream = click_sound
	sfx.play()
	
	navigations.append("prize")
	_hide_all()
	
	prize.visible = true
	prize.show_prize()
	
func _on_rank_back():
	sfx.stream = click_sound
	sfx.play()
	
	navigations.pop_back()
	_hide_all()
	
	if navigations.is_empty():
		animated_background.set_stage(4, true)
		await get_tree().process_frame
		main_menu.visible = true
		main_menu.show_menu(true)
		return
		
	if navigations.back() == "gameplay":
		animated_background.set_stage(4)
		gameplay.visible = true
		gameplay.back_to_gameplay()

func _on_rank_error():
	_show_panel_error()
	
#------------------------------ dictionary ------------------------------------#
func _on_dictionary_back():
	sfx.stream = click_sound
	sfx.play()
	
	navigations.pop_back()
	_hide_all()
	
	if navigations.back() == "gameplay":
		gameplay.visible = true
		gameplay.back_to_gameplay()
		
#------------------------------ prize ------------------------------------#
func _on_prize_back():
	sfx.stream = click_sound
	sfx.play()
	
	navigations.pop_back()
	_hide_all()
	
	if navigations.back() == "rank":
		rank.visible = true
		rank.show_ranks()
		
func _on_prize_error():
	_show_panel_error()

































