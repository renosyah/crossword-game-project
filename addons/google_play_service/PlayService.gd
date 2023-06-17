extends Node

signal on_sign_in_success(_user)
signal on_sign_in_failed(_code)
signal on_sign_out

var _android_play_service_plugin
var _is_android_app :bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_is_android_app = ["Android"].has(OS.get_name())
	
	if _is_android_app:
		_android_play_service_plugin = Engine.get_singleton("PlayGameServicesGodot")
		
		_android_play_service_plugin._on_sign_in_success.connect(_on_sign_in_success)
		_android_play_service_plugin._on_sign_in_failed.connect(_on_sign_in_failed)
		_android_play_service_plugin._on_sign_out_success.connect(_on_sign_out_success)
		_android_play_service_plugin._on_sign_out_failed.connect(_on_sign_out_failed)
		
		_init()
		
	await get_tree().create_timer(3).timeout
		
	if isSignedIn():
		signOut()
		
func _init():
	if _android_play_service_plugin != null:
		# init(enablePopups: Boolean, requestEmail: Boolean, requestProfile: Boolean, requestToken: String)
		_android_play_service_plugin.init(true, true, true, PlayServiceConfig.CLIENT_ID)
	
	
func isGooglePlayServicesAvailable() -> bool:
	if _android_play_service_plugin == null:
		return false
		
	return _android_play_service_plugin.isGooglePlayServicesAvailable()
	
func signIn():
	if not isGooglePlayServicesAvailable():
		return
		
	_android_play_service_plugin.signIn()
	
func signOut():
	if not isGooglePlayServicesAvailable():
		return
		
	_android_play_service_plugin.signOut()
	
func isSignedIn() -> bool:
	if not isGooglePlayServicesAvailable():
		return false
		
	return _android_play_service_plugin.isSignedIn()
	
	
func _on_sign_in_success():
	if _android_play_service_plugin == null:
		return
		
	var _user :String = _android_play_service_plugin.getUserProfileHolder()
	print("user login : %s" % _user)
	
	var data :Dictionary = JSON.parse_string(_user)
	if data == null:
		return
		
	emit_signal("on_sign_in_success", User.new(data))
	
func _on_sign_in_failed():
	if _android_play_service_plugin == null:
		return
		
	var _code: int= _android_play_service_plugin.getSignInErrorStatusCodeHolder()
	print("error sign in play service : code %s" % _code)
	emit_signal("on_sign_in_failed", _code)
	
func _on_sign_out_success():
	_on_sign_out()
	
func _on_sign_out_failed():
	_on_sign_out()
	
func _on_sign_out():
	emit_signal("on_sign_out")
	
class User:
	var id: String
	var displayName: String
	var email: String
	#var token: String
	
	func _init(_data :Dictionary):
		self.id = _data["id"]
		self.displayName = _data["displayName"]
		self.email = _data["email"]
		#self.token = _data["token"]
