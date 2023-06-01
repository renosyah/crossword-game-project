extends Control

@onready var animated_background :AnimatedBackground = $CanvasLayer/Control/animated_background
@onready var loading = $CanvasLayer/Control/loading

# menu
@onready var login = $CanvasLayer/Control/SafeArea/login
@onready var main_menu = $CanvasLayer/Control/SafeArea/main_menu
@onready var gameplay = $CanvasLayer/Control/SafeArea/gameplay
@onready var rank = $CanvasLayer/Control/SafeArea/rank

# Called when the node enters the scene tree for the first time.
func _ready():
	loading.visible = false
	main_menu.visible = false
	gameplay.visible = false
	login.visible = false
	rank.visible = false
	
	Admob.banner_loaded.connect(_admob_banner_loaded)
	OAuth2.sign_in_completed.connect(_sign_in_completed)
	
	# have login session
	if not Global.player.player_id.is_empty():
		loading.visible = true
		
		await _preparing()
		
		animated_background.set_stage(3)
		loading.visible = false
		_show_main_menu()
		return
		
	await get_tree().create_timer(1).timeout
	animated_background.set_stage(1)
	login.visible = true
	login.show_icon()
	
	await _preparing()
	
	animated_background.set_stage(2)
	login.show_login_form()
	
func _preparing():
	# prepare admob, and regenerator
	await _init_admob()
	
	Global.regenerate_hp.run_regenerating()
	await Global.regenerate_hp.ready_to_regenerate
	
	Global.regenerate_hint.run_regenerating()
	await Global.regenerate_hint.ready_to_regenerate
	
func _init_admob():
	Admob.initialize()
	await Admob.initialization_finish
	
	if not Admob.get_is_banner_loaded():
		Admob.load_banner()
#------------------------------ login ------------------------------------#
func _on_login_on_sign_in_press():
	OAuth2.sign_in()
	
func _sign_in_completed():
	OAuth2.get_profile_info()
	var profile :OAuth2.OAuth2UserInfo = await OAuth2.profile_info
	if profile != null:
		Global.player.player_id = profile.id
		Global.player.player_email = profile.email
		Global.player.player_name = profile.given_name
		Global.player.player_avatar = profile.picture
		Global.player.save_data(Global.player_data_file)
	
	login.hide_login_form()
	await login.login_form_hide
	
	_to_main_menu()
	
#------------------------------ main menu ------------------------------------#
func _to_main_menu():
	login.visible = false
	animated_background.set_stage(3, true)
	loading.visible = true
	
	# simple delay
	# future probably to init score data
	# idk
	await get_tree().create_timer(3).timeout
	
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
	animated_background.set_stage(4)
	gameplay.visible = true
	gameplay.generate_puzzle()
	
func _on_main_menu_setting():
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
	animated_background.set_stage(4)
	rank.visible = true
	rank.show_ranks()
	
func _on_gameplay_rank():
	animated_background.set_stage(4, true)
	rank.visible = true
	rank.show_ranks()
	
func _on_main_menu_back_press():
	rank.visible = false
	animated_background.set_stage(4, true)
	main_menu.show_menu(true)
	
#------------------------------ gameplay ------------------------------------#
func _on_gameplay_back_press(_is_on_rank_menu :bool):
	if _is_on_rank_menu:
		rank.visible = false
		animated_background.set_stage(4)
		return
		
	animated_background.set_stage(4, true)
	main_menu.show_menu(true)
	await get_tree().process_frame
	gameplay.visible = false












