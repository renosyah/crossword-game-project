extends Control

@onready var animated_background :AnimatedBackground = $CanvasLayer/Control/animated_background
@onready var loading = $CanvasLayer/Control/loading

# menu
@onready var login = $CanvasLayer/Control/SafeArea/login
@onready var main_menu = $CanvasLayer/Control/SafeArea/main_menu
@onready var gameplay = $CanvasLayer/Control/SafeArea/gameplay

# Called when the node enters the scene tree for the first time.
func _ready():
	loading.visible = false
	main_menu.visible = false
	gameplay.visible = false
	
	OAuth2.sign_in_completed.connect(_sign_in_completed)
	Admob.initialization_finish.connect(_admob_initialization_finish)
	
	if not Global.player.player_id.is_empty():
		_to_main_menu()
		return
		
	await get_tree().create_timer(1).timeout
	animated_background.set_stage(1)
	login.visible = true
	login.show_icon()
	
	await get_tree().create_timer(2).timeout
	animated_background.set_stage(2)
	login.show_login_form()
	
func _on_login_on_sign_in_press():
	OAuth2.sign_in()
	
func _sign_in_completed():
	OAuth2.get_profile_info()
	var profile :OAuth2.OAuth2UserInfo = await OAuth2.profile_info
	if profile != null:
		Global.player.player_id = profile.id
		Global.player.player_name = profile.given_name
		Global.player.player_avatar = profile.picture
		Global.player.save_data(Global.player_data_file)
		
	login.hide_login_form()
	await login.login_form_hide
	
	_to_main_menu()
	
func _to_main_menu():
	login.visible = false
	loading.visible = true
	animated_background.set_stage(3, true)
	Admob.initialize()
	
func _admob_initialization_finish():
	loading.visible = false
	animated_background.set_stage(3)
	
	main_menu.visible = true
	main_menu.show_menu()
	
func _on_main_menu_play():
	animated_background.set_stage(4)
	gameplay.visible = true
	
	Global.reset_player()
	Global.generate_words()
	gameplay.generate_puzzle()

func _on_main_menu_rank():
	pass
	
func _on_gameplay_back_press():
	animated_background.set_stage(4, true)
	gameplay.visible = false
	main_menu.show_menu(true)







