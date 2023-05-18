extends Node

signal initialization_finish

signal consent_form_dismissed
signal consent_status_changed(message)
signal consent_form_load_failure(code, error)
signal consent_info_update_success(message)
signal consent_info_update_failure(code, error)

signal banner_loaded
signal banner_failed_to_load
signal banner_opened
signal banner_clicked
signal banner_closed
signal banner_recorded_impression
signal banner_destroyed

signal interstitial_failed_to_load
signal interstitial_loaded
signal interstitial_failed_to_show
signal interstitial_opened
signal interstitial_clicked
signal interstitial_closed
signal interstitial_recorded_impression

signal rewarded_ad_failed_to_load
signal rewarded_ad_loaded
signal rewarded_ad_failed_to_show
signal rewarded_ad_opened
signal rewarded_ad_clicked
signal rewarded_ad_closed
signal rewarded_ad_recorded_impression
signal user_earned_rewarded(reward_type, amount)

# beta, maybe latter
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

var _android_admob_plugin
var _is_android_app :bool = false
var _is_initialize_valid :bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_is_android_app = ["Android"].has(OS.get_name())
	
	if _is_android_app:
		_android_admob_plugin = Engine.get_singleton("AdMob")
		
		# initialization signal
		_android_admob_plugin.initialization_complete.connect(_initialization_complete)
		
		# consent signal
		_android_admob_plugin.consent_form_dismissed.connect(_consent_form_dismissed)
		_android_admob_plugin.consent_status_changed.connect(_consent_status_changed)
		_android_admob_plugin.consent_form_load_failure.connect(_consent_form_load_failure)
		_android_admob_plugin.consent_info_update_success.connect(_consent_info_update_success)
		_android_admob_plugin.consent_info_update_failure.connect(_consent_info_update_failure)

		# rewarded ad signal
		_android_admob_plugin.rewarded_ad_loaded.connect(_rewarded_ad_loaded)
		_android_admob_plugin.rewarded_ad_failed_to_load.connect(_rewarded_ad_failed_to_load)
		_android_admob_plugin.rewarded_ad_failed_to_show.connect(_rewarded_ad_failed_to_show)
		_android_admob_plugin.rewarded_ad_opened.connect(_rewarded_ad_opened)
		_android_admob_plugin.rewarded_ad_clicked.connect(_rewarded_ad_clicked)
		_android_admob_plugin.rewarded_ad_closed.connect(_rewarded_ad_closed)
		_android_admob_plugin.user_earned_rewarded.connect(_user_earned_rewarded)
		
		# banner ad signal
		_android_admob_plugin.banner_loaded.connect(_banner_loaded)
		_android_admob_plugin.banner_failed_to_load.connect(_banner_failed_to_load)
		_android_admob_plugin.banner_opened.connect(_banner_opened)
		_android_admob_plugin.banner_clicked.connect(_banner_clicked)
		_android_admob_plugin.banner_closed.connect(_banner_closed)
		_android_admob_plugin.banner_recorded_impression.connect(_banner_recorded_impression)
		_android_admob_plugin.banner_destroyed.connect(_banner_destroyed)
		
		#interstitial
		_android_admob_plugin.interstitial_failed_to_load.connect(_interstitial_failed_to_load)
		_android_admob_plugin.interstitial_loaded.connect(_interstitial_loaded)
		_android_admob_plugin.interstitial_failed_to_show.connect(_interstitial_failed_to_show)
		_android_admob_plugin.interstitial_opened.connect(_interstitial_opened)
		_android_admob_plugin.interstitial_clicked.connect(_interstitial_clicked)
		_android_admob_plugin.interstitial_closed.connect(_interstitial_closed)
		_android_admob_plugin.interstitial_recorded_impression.connect(_interstitial_recorded_impression)
		
		
func _is_valid() -> bool:
	if not _is_android_app:
		return false
		
	if _android_admob_plugin == null:
		return false
		
	if not _is_initialize_valid:
		return false
		
	return true
	
#-----------------------------------------------------------------------------#
# is_for_child
@export var is_for_child :bool = false

#G : GAY?, MA : Mature, PG : Parent Guide,T :Teen, :All?
@export var content_rating :String = ""

# becarefull, set to true if prod only
@export var is_real :bool = AdmobConfig.IS_REAL

# idk, just set false
@export var is_test_europe_user_consent :bool = false

#-----------------------------------------------------------------------------#
# initialize
func initialize():
	# if other platform running, just set to valid :)
	if not _is_android_app or _is_initialize_valid:
		emit_signal("initialization_finish")
		return
		
	if _android_admob_plugin == null:
		return
		
	_android_admob_plugin.initialize(
		is_for_child, content_rating, is_real, is_test_europe_user_consent
	)
	
func _initialization_complete():
	var _description :String = _android_admob_plugin.get_initialization_description()
	var _is_initialized :bool = _android_admob_plugin.get_is_initialized()
	emit_signal("initialization_finish")
	
	if not _is_initialized:
		print("initialization_failed : %s " % _description)
		return
	
	_is_initialize_valid = true
	print("initialization_complete : %s " % _description)
	
#-----------------------------------------------------------------------------#
# user_consent
func request_user_consent():
	if not _is_valid():
		return
		
	_android_admob_plugin.request_user_consent()
	
func reset_consent_state():
	if not _is_valid():
		return
		
	_android_admob_plugin.reset_consent_state()
	
func _consent_form_dismissed():
	emit_signal("consent_form_dismissed")
	
func _consent_status_changed():
	var message :String = _android_admob_plugin.get_user_consent_status_message()
	emit_signal("consent_status_changed",message)
	
func _consent_form_load_failure():
	var error_data :PackedStringArray = _android_admob_plugin.get_form_consent_load_error()
	emit_signal("consent_form_load_failure", int(error_data[0]), error_data[1])
	
func _consent_info_update_success():
	var message :String = _android_admob_plugin.get_consent_info_update_message()
	emit_signal("consent_info_update_success", message)
	
func _consent_info_update_failure():
	var error_data :PackedStringArray = _android_admob_plugin.get_consent_info_update_failure()
	emit_signal("consent_info_update_failure", int(error_data[0]), error_data[1])
	

#-----------------------------------------------------------------------------#

const size_banner = "BANNER"
const size_banner_large = "LARGE_BANNER"
const size_banner_medium = "MEDIUM_RECTANGLE"
const size_banner_full = "FULL_BANNER"
const size_banner_leaderboard = "LEADERBOARD"
const size_banner_adaptive = "ADAPTIVE"

const position_bottom = 0
const position_top = 1

# banner
# default value is id testing
@export var banner_ad_unit_id :String = AdmobConfig.BANNER_AD_UNIT_ID
@export var banner_position :int = position_bottom
@export var banner_size :String = size_banner
@export var banner_show_instantly :bool = false
@export var respect_safe_area :bool = true

# banner
func load_banner():
	if not _is_valid():
		return
		
	_android_admob_plugin.load_banner(
		banner_ad_unit_id,
		banner_position,
		banner_size,
		banner_show_instantly,
		respect_safe_area
	)
	
func destroy_banner():
	if not _is_valid():
		return
		
	_android_admob_plugin.destroy_banner()
	
func show_banner():
	if not _is_valid():
		return
		
	_android_admob_plugin.show_banner()
	
func hide_banner():
	if not _is_valid():
		return
		
	_android_admob_plugin.hide_banner()
	
func get_banner_width() -> int:
	if not _is_valid():
		return 0
		
	return _android_admob_plugin.get_banner_width()
	
func get_banner_height() -> int:
	if not _is_valid():
		return 0
		
	return _android_admob_plugin.get_banner_height()
	
func get_banner_width_in_pixels() -> int:
	if not _is_valid():
		return 0
		
	return _android_admob_plugin.get_banner_width_in_pixels()
	
func get_banner_height_in_pixels() -> int:
	if not _is_valid():
		return 0
		
	return _android_admob_plugin.get_banner_height_in_pixels()
	
func get_is_banner_loaded() -> bool:
	if not _is_valid():
		return false
		
	return _android_admob_plugin.get_is_banner_loaded()
	
	
func _banner_loaded():
	emit_signal("banner_loaded")
	
func _banner_failed_to_load():
	emit_signal("banner_failed_to_load")
	
func _banner_opened():
	emit_signal("banner_opened")
	
func _banner_clicked():
	emit_signal("banner_clicked")
	
func _banner_closed():
	emit_signal("banner_closed")
	
func _banner_recorded_impression():
	emit_signal("banner_recorded_impression")
	
func _banner_destroyed():
	emit_signal("banner_destroyed")
	
#-----------------------------------------------------------------------------#
# interstitia
# default value is id testing
@export var interstitial_ad_unit_id :String = AdmobConfig.INTERSTITIAL_AD_UNIT_ID

# interstitial
func load_interstitial():
	if not _is_valid():
		return
		
	_android_admob_plugin.load_interstitial(interstitial_ad_unit_id)
	
func show_interstitial():
	if not _is_valid():
		return
		
	_android_admob_plugin.show_interstitial()
	
func get_is_interstitial_loaded() -> bool:
	if not _is_valid():
		return false
		
	return _android_admob_plugin.get_is_interstitial_loaded()
	
func _interstitial_failed_to_load():
	emit_signal("interstitial_failed_to_load")
	
func _interstitial_loaded():
	emit_signal("interstitial_loaded")
	
func _interstitial_failed_to_show():
	emit_signal("interstitial_failed_to_show")
	
func _interstitial_opened():
	emit_signal("interstitial_opened")
	
func _interstitial_clicked():
	emit_signal("interstitial_clicked")
	
func _interstitial_closed():
	emit_signal("interstitial_closed")
	
func _interstitial_recorded_impression():
	emit_signal("interstitial_recorded_impression")
	

#-----------------------------------------------------------------------------#
# rewarded
# default value is id testing
@export var reward_ad_unit_id = AdmobConfig.REWARD_AD_UNIT_ID

func load_rewarded():
	if not _is_valid():
		return
		
	_android_admob_plugin.load_rewarded(reward_ad_unit_id)
	
func show_rewarded():
	if not _is_valid():
		return
		
	_android_admob_plugin.show_rewarded()
	
func get_is_rewarded_loaded() -> bool:
	if not _is_valid():
		return false
		
	return _android_admob_plugin.get_is_rewarded_loaded()
	
func _rewarded_ad_loaded():
	emit_signal("rewarded_ad_loaded")
	
func _rewarded_ad_failed_to_load():
	emit_signal("rewarded_ad_failed_to_load")
	
func _rewarded_ad_failed_to_show():
	emit_signal("rewarded_ad_failed_to_show")
	
func _rewarded_ad_opened():
	emit_signal("rewarded_ad_opened")
	
func _rewarded_ad_clicked():
	emit_signal("rewarded_ad_clicked")
	
func _rewarded_ad_closed():
	emit_signal("rewarded_ad_closed")
	
func _user_earned_rewarded():
	var data :PackedStringArray = _android_admob_plugin.get_user_earned_rewarded_data()
	emit_signal("user_earned_rewarded", data[0], int(data[1]))
	
# rewarded interstitial
func load_rewarded_interstitial():
	pass
func show_rewarded_interstitial():
	pass
func get_is_rewarded_interstitial_loaded():
	pass
func _rewarded_ad_recorded_impression():
	emit_signal("rewarded_ad_recorded_impression")
	
	

