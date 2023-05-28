extends Control

@onready var score = $CanvasLayer/Control/score
@onready var label = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/Label
@onready var loading = $CanvasLayer/Control/loading
@onready var popup_message = $CanvasLayer/Control/popup_message
@onready var test_reward_adds = $CanvasLayer/Control/SafeArea/VBoxContainer/VBoxContainer/VBoxContainer/test_reward_adds


# Called when the node enters the scene tree for the first time.
func _ready():
	score.visible = false
	loading.visible = true
	
	OAuth2.profile_info.connect(_profile_info)
	OAuth2.sign_out_completed.connect(_sign_out_completed)
	OAuth2.failed.connect(_failed)
	
	if Global.player_id.is_empty():
		OAuth2.get_profile_info()
		
	else:
		loading.visible = false
		label.text = "Welcome : %s" % Global.player_name
	
	
	test_reward_adds.disabled = true
	
	# test admob reward
	if Admob.get_is_rewarded_loaded():
		test_reward_adds.disabled = false
		
	else:
		Admob.rewarded_ad_loaded.connect(_rewarded_ad_loaded)
		Admob.rewarded_ad_failed_to_load.connect(_rewarded_ad_failed_to_load)
		Admob.rewarded_ad_failed_to_show.connect(_rewarded_ad_failed_to_show)
		Admob.user_earned_rewarded.connect(_user_earned_rewarded)
		
		Admob.load_rewarded()
		
	# test admob banner
	if Admob.get_is_banner_loaded():
		Admob.show_banner()
	else:
		Admob.banner_loaded.connect(_banner_loaded)
		Admob.banner_failed_to_load.connect(_banner_failed_to_load)
		
		Admob.load_banner()
		
func _rewarded_ad_failed_to_load():
	popup_message.show_popup_message("Error", "rewarded_ad_failed_to_load")
	
func _rewarded_ad_loaded():
	test_reward_adds.disabled = false
	
func _rewarded_ad_failed_to_show():
	popup_message.show_popup_message("Error", "rewarded_ad_failed_to_show")
	
func _on_test_adds_pressed():
	# hide banner!
	# prevent from overlapping
	# with reward
	Admob.hide_banner()
	Admob.show_rewarded()
	
func _user_earned_rewarded(reward_type :String, amount :int):
	popup_message.show_popup_message(
		"Success", "user_earned_rewarded : reward_type =%s & amount=%s" % [reward_type, amount],
		popup_message.color_success
	)
	await popup_message.on_all_popup_closed
	Admob.show_banner()
	
func _banner_loaded():
	Admob.show_banner()
	
func _banner_failed_to_load():
	popup_message.show_popup_message("Error", "banner_failed_to_load")
	
func _profile_info(profile : OAuth2.OAuth2UserInfo):
	loading.visible = false
	Global.player_id = profile.id
	Global.player_name = profile.given_name
	
	label.text = "Welcome : %s" % Global.player_name
	
func _sign_out_completed():
	loading.visible = false
	get_tree().change_scene_to_file("res://menu/login/login.tscn")
	
func _failed(message :String):
	loading.visible = false
	popup_message.show_popup_message("Error", message)
	
func _on_play_pressed():
	Global.reset_player()
	Global.generate_words()
	get_tree().change_scene_to_file("res://gameplay/gameplay.tscn")
	
func _on_score_button_pressed():
	score.visible = true
	score.display_score(Global.get_scores())
	
func _on_sign_out_pressed():
	if loading.visible:
		return
		
	loading.visible = true
	Admob.destroy_banner()
	OAuth2.sign_out()







