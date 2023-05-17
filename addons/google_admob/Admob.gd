extends Node

signal initialization_complete
signal initialization_failed(error)

signal consent_form_dismissed
signal consent_status_changed(message)
signal consent_form_load_failure(code, error)
signal consent_info_update_success(message)
signal consent_info_update_failure(code, error)

signal banner_loaded
signal banner_failed_to_load(code)
signal banner_opened
signal banner_clicked
signal banner_closed
signal banner_recorded_impression
signal banner_destroyed

signal interstitial_failed_to_load(code)
signal interstitial_loaded
signal interstitial_failed_to_show(code)
signal interstitial_opened
signal interstitial_clicked
signal interstitial_closed
signal interstitial_recorded_impression

signal rewarded_ad_failed_to_load(code)
signal rewarded_ad_loaded
signal rewarded_ad_failed_to_show(code)
signal rewarded_ad_opened
signal rewarded_ad_clicked
signal rewarded_ad_closed
signal rewarded_ad_recorded_impression
signal user_earned_rewarded(text_type, amount)

signal rewarded_interstitial_ad_failed_to_load(code)
signal rewarded_interstitial_ad_loaded
signal rewarded_interstitial_ad_failed_to_show(code)
signal rewarded_interstitial_ad_opened
signal rewarded_interstitial_ad_clicked
signal rewarded_interstitial_ad_closed
signal rewarded_interstitial_ad_recorded_impression


#App Open ca-app-pub-3940256099942544/3419835294
#Banner ca-app-pub-3940256099942544/6300978111
#Interstitial ca-app-pub-3940256099942544/1033173712
#Interstitial Video ca-app-pub-3940256099942544/8691691433
#Rewarded ca-app-pub-3940256099942544/5224354917
#Rewarded Interstitial ca-app-pub-3940256099942544/5354046379
#Native Advanced ca-app-pub-3940256099942544/2247696110
#Native Advanced Video ca-app-pub-3940256099942544/1044960115

# is_for_child
@export var is_for_child :bool = false

# G, PG ,T and MA
@export var content_rating :String = "PG"

# becarefull, set to true if prod only
@export var is_real :bool = false 

# idk, just set false
@export var is_test_europe_user_consent :bool = false

var android_admob_plugin
var is_android_app = false
var is_initialize_valid = false

# Called when the node enters the scene tree for the first time.
func _ready():
	is_android_app = ["Android"].has(OS.get_name())
	
	if is_android_app:
		android_admob_plugin = Engine.get_singleton("AdMob")
		# initialization signal
		android_admob_plugin.initialization_complete.connect(_initialization_complete)
		
		# rewarded ad signal
		android_admob_plugin.rewarded_ad_failed_to_load.connect(_rewarded_ad_failed_to_load)
		android_admob_plugin.rewarded_ad_loaded.connect(_rewarded_ad_loaded)
		android_admob_plugin.rewarded_ad_failed_to_show.connect(_rewarded_ad_failed_to_show)
		android_admob_plugin.rewarded_ad_opened.connect(_rewarded_ad_opened)
		android_admob_plugin.rewarded_ad_clicked.connect(_rewarded_ad_clicked)
		android_admob_plugin.rewarded_ad_closed.connect(_rewarded_ad_closed)
		android_admob_plugin.rewarded_ad_recorded_impression.connect(_rewarded_ad_recorded_impression)
		
func _is_valid() -> bool:
	if not is_android_app:
		return false
		
	if android_admob_plugin == null:
		return false
		
	if not is_initialize_valid:
		return false
		
	return true
	
# initialize
func initialize():
	if not is_android_app:
		return
		
	if android_admob_plugin == null:
		return
		
	android_admob_plugin.initialize(
		is_for_child, content_rating, is_real, is_test_europe_user_consent
	)
	
func _initialization_complete(code :int, text :String):
	if not _get_is_initialized():
		emit_signal("initialization_failed", _get_initialization_description())
		return
	
	is_initialize_valid = true
	emit_signal("initialization_complete")
	
func _get_is_initialized() -> bool:
	if not _is_valid():
		return false
		
	return android_admob_plugin.get_is_initialized() 
	
func _get_initialization_description() -> String:
	return android_admob_plugin.get_initialization_description()
	
# user_consent
func request_user_consent():
	pass
func reset_consent_state():
	pass
	
# banner
func load_banner():
	pass
func destroy_banner():
	pass
func show_banner():
	pass
func hide_banner():
	pass
func get_banner_width():
	pass
func get_banner_height():
	pass
func get_banner_width_in_pixels():
	pass
func get_banner_height_in_pixels():
	pass
func get_is_banner_loaded():
	pass
	
# interstitial
func load_interstitial():
	pass
func show_interstitial():
	pass
	
# rewarded
# default value is id testing
@export var reward_ad_unit_id = "ca-app-pub-3940256099942544/5224354917"

func load_rewarded():
	if not _is_valid():
		return
		
	android_admob_plugin.load_rewarded(reward_ad_unit_id)
	
func show_rewarded():
	if not _is_valid():
		return
		
	android_admob_plugin.show_rewarded()
	
func get_is_rewarded_loaded():
	pass
	
func _rewarded_ad_loaded():
	emit_signal("rewarded_ad_loaded")
	
func _rewarded_ad_failed_to_load(code :int):
	emit_signal("rewarded_ad_failed_to_load", code)
	
func _rewarded_ad_failed_to_show(code :int):
	emit_signal("rewarded_ad_failed_to_show", code)
	
func _rewarded_ad_opened():
	emit_signal("rewarded_ad_opened")
	
func _rewarded_ad_clicked():
	emit_signal("rewarded_ad_clicked")
	
func _rewarded_ad_closed():
	emit_signal("rewarded_ad_closed")
	
func _rewarded_ad_recorded_impression():
	emit_signal("rewarded_ad_recorded_impression")
	
	
# rewarded interstitial
func load_rewarded_interstitial():
	pass
func show_rewarded_interstitial():
	pass
func get_is_interstitial_loaded():
	pass
func get_is_rewarded_interstitial_loaded():
	pass
	
	

