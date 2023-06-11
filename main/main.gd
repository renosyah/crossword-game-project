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

var current_menu :String = "login"
var has_error :bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	var is_web_app :bool = ["Web"].has(OS.get_name())
	
	loading.visible = false
	main_menu.visible = false
	gameplay.visible = false
	login.visible = false
	rank.visible = false
	dictionary.visible = false
	error_display.visible = false
	
	Admob.banner_loaded.connect(_admob_banner_loaded)
	
	# have login session
	if not Global.player.player_id.is_empty():
		loading.visible = true
		
		await _preparing()
		
		if has_error:
			_show_panel_error()
			return
		
		current_menu = "main_menu"
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
	current_menu = "login"
	
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
	if current_menu == "rank":
		_on_main_menu_back_press()
		return
		
	if current_menu == "gameplay":
		gameplay.on_back_button_pressed()
		return
		
	if current_menu == "gameplay/rank":
		gameplay.on_back_button_pressed()
		return
		
	if current_menu == "gameplay/dictionary":
		gameplay.on_back_button_pressed()
		return
		
	if current_menu == "main_menu" or current_menu == "login":
		get_tree().quit()
	
func _show_panel_error():
	error_display.visible = true
	error_display.error_title = tr("NO_INTERNET")
	error_display.error_description = tr("NO_INTERNET_DESCRIPTION")
	error_display.show_error()
	
	loading.visible = false
	main_menu.visible = false
	gameplay.visible = false
	login.visible = false
	rank.visible = false
	dictionary.visible = false
	
#------------------------------ login ------------------------------------#
func _on_login_login_completed():
	_to_main_menu()
	
func _get_profile():
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
	
	current_menu = "main_menu"
	animated_background.set_stage(3)
	loading.visible = false
	_show_main_menu()
	
func _show_main_menu():
	main_menu.visible = true
	Global.reset_player()
	Global.generate_words()
	main_menu.show_menu()
	
func _admob_banner_loaded():
	Admob.show_banner()
	
func _on_main_menu_play():
	sfx.stream = click_sound
	sfx.play()
	
	current_menu = "gameplay"
	animated_background.set_stage(4)
	gameplay.visible = true
	gameplay.generate_puzzle()

func _on_main_menu_logout():
	sfx.stream = click_sound
	sfx.play()
	
	loading.visible = true
	OAuth2.sign_out()
	await OAuth2.sign_out_completed
	
	loading.visible = false
	animated_background.set_stage(3, true)
	await animated_background.stage_finish
	
	Global.player.delete_data(Global.player_data_file)
	Global.player = PlayerData.new()
	get_tree().reload_current_scene()
	
func _on_main_menu_rank():
	sfx.stream = click_sound
	sfx.play()
	
	current_menu = "rank"
	animated_background.set_stage(4)
	rank.visible = true
	rank.show_ranks()
	
func _on_main_menu_back_press():
	sfx.stream = click_sound
	sfx.play()
	
	current_menu = "main_menu"
	rank.visible = false
	animated_background.set_stage(4, true)
	main_menu.show_menu(true)
	
#------------------------------ gameplay ------------------------------------#
func _on_gameplay_rank():
	sfx.stream = click_sound
	sfx.play()
	
	current_menu = "gameplay/rank"
	animated_background.set_stage(4, true)
	rank.visible = true
	rank.show_ranks()
	
func _on_gameplay_dictionary():
	sfx.stream = click_sound
	sfx.play()
	
	current_menu = "gameplay/dictionary"
	animated_background.set_stage(4, true)
	dictionary.visible = true
	dictionary.show_dictionary()
	
func _on_gameplay_add_to_dictionary(word :String):
	if dictionary.words.has(word):
		return
		
	dictionary.words.append(word)
	dictionary.refresh_dictionary()
	
func _on_gameplay_back_press(_is_on_rank_menu :bool, _is_on_dictionary_menu :bool):
	if _is_on_rank_menu or _is_on_dictionary_menu:
		current_menu = "gameplay"
		rank.visible = false
		dictionary.visible = false
		
		animated_background.set_stage(4)
		return
		
	current_menu = "main_menu"
	animated_background.set_stage(4, true)
	main_menu.show_menu(true)
	await get_tree().process_frame
	gameplay.visible = false

























