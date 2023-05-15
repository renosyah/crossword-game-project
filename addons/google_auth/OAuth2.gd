extends Node

signal sign_in_completed
signal sign_in_expired
signal get_profile
signal sign_out_completed

var redirect_server :TCPServer = TCPServer.new()
var redirect_uri :String = "http://%s:%s" % [Credentials.LOCAL_BINDING, Credentials.PORT]

var redirect_code
var token
var refresh_token

var is_web_app : bool

var is_android_app :bool
var android_webview_popup_plugin

var http_request_token_from_auth = HTTPRequest.new()
var http_request_refresh_tokens = HTTPRequest.new()
var http_request_validate_tokens = HTTPRequest.new()
var http_request_profile_info = HTTPRequest.new()
var http_request_revoke_token_from_auth = HTTPRequest.new()

var simple_delay :Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	is_web_app = ["Web"].has(OS.get_name())
	is_android_app =  ["Android"].has(OS.get_name())
	
	# because browser use broken as CORS stupid bitch
	# this will solve it
	if is_web_app:
		http_request_token_from_auth.accept_gzip = false
		http_request_refresh_tokens.accept_gzip = false
		http_request_validate_tokens.accept_gzip = false
		http_request_profile_info.accept_gzip = false
		http_request_revoke_token_from_auth.accept_gzip = false
	
	if is_android_app:
		android_webview_popup_plugin = Engine.get_singleton("WebViewPopUp")
	
	add_child(http_request_token_from_auth)
	add_child(http_request_refresh_tokens)
	add_child(http_request_validate_tokens)
	add_child(http_request_profile_info)
	add_child(http_request_revoke_token_from_auth)
	
	simple_delay.wait_time = 1
	simple_delay.one_shot = true
	simple_delay.autostart = false
	add_child(simple_delay)
	
	set_process(false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			set_process(false)
			
			if is_android_app and android_webview_popup_plugin != null:
				android_webview_popup_plugin.ClosePopUp()
				
			var auth_code = request.split("&scope")[0].split("=")[1]
			_get_token_from_auth(auth_code)
			
			connection.put_data(("HTTP/1.1 %d\r\n" % 200).to_ascii_buffer())
			connection.put_data(_load_HTML("res://addons/google_auth/display_page.csv").to_ascii_buffer())
			redirect_server.stop()
	
func _get_token_from_auth(auth_code :String):
	var headers = PackedStringArray([
		"Content-Type: application/x-www-form-urlencoded",
	])
	
	var _redirect_uri_value :String = redirect_uri
	
	if is_web_app:
		_redirect_uri_value = Credentials.WEB_REDIRECT_URL
	
	var body_parts :Array = [
		"code=%s" % auth_code, 
		"client_id=%s" % Credentials.CLIENT_ID,
		"client_secret=%s" % Credentials.WEB_CLIENT_SECRET,
		"redirect_uri=%s" % _redirect_uri_value,
		"grant_type=authorization_code",
		"access_type=offline",
		"prompt=consent"
	]
	
	var body = "&".join(PackedStringArray(body_parts))
	
	var error = http_request_token_from_auth.request(
		Credentials.TOKEN_REQ_SERVER, headers, HTTPClient.METHOD_POST, body
	)
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
		return
		
	var result = await http_request_token_from_auth.request_completed
	if result[0] != HTTPRequest.RESULT_SUCCESS:
		return
		
	var response_body :Dictionary = JSON.parse_string((result[3] as PackedByteArray).get_string_from_utf8())
	
	if response_body.has("access_token"):
		token = response_body["access_token"]
		
	if response_body.has("refresh_token"):
		refresh_token = response_body["refresh_token"]
		
	if token == null:
		return
		
	_save_tokens()
	emit_signal("sign_in_completed")
	
func sign_in():
	_get_auth_code()
	
func sign_out():
	_revoke_auth_code()
	
func check_sign_in_status():
	# just simple delay
	# to prevent request
	# on page loaded
	simple_delay.start()
	await simple_delay.timeout
	
	_load_tokens()
	
	var hasCode :bool = await _get_code_from_url_query()
	if hasCode:
		return
		
	if token == null:
		_failed_sign_in_exipired()
		return
		
	var token_valid :bool = await _is_token_valid()
	if not token_valid:
		
		# try refresh if not valid
		if refresh_token == null:
			_failed_sign_in_exipired()
			return
			
		var ok = await _refresh_tokens()
		if not ok:
			_failed_sign_in_exipired()
			return
			
		
	emit_signal("sign_in_completed")
	
func _failed_sign_in_exipired():
	_delete_tokens()
	emit_signal("sign_in_expired")
	
func _get_code_from_url_query() -> bool:
	if is_web_app:
		var auth_code = JavaScriptBridge.eval("""
			var url_string = window.location.href;
			var url = new URL(url_string);
			url.searchParams.get('code');
		""")
		if auth_code == null:
			return false
			
		if str(auth_code) == "<null>":
			return false
			
		if str(auth_code) == redirect_code:
			return false
			
		redirect_code = str(auth_code)
		_save_tokens()
		
		await _get_token_from_auth(redirect_code)
		#JavaScriptBridge.eval('window.location.replace("%s")' % Credentials.WEB_REDIRECT_URL)
		return true
		
	return false

func _get_auth_code():
	# for web
	if is_web_app:
		var body_parts :Array = [
			"client_id=%s" % Credentials.CLIENT_ID,
			"redirect_uri=%s" % Credentials.WEB_REDIRECT_URL,
			"response_type=code",
			"scope=https://www.googleapis.com/auth/userinfo.profile",
		]
		var url :String = Credentials.AUTH_SERVER + "?" + "&".join(PackedStringArray(body_parts))
		JavaScriptBridge.eval('window.location.replace("%s")' % url)
		
	# for android
	elif is_android_app:
		set_process(true)
		
		if not redirect_server.is_listening():
			redirect_server.listen(Credentials.PORT, Credentials.LOCAL_BINDING)
		
		var body_parts :Array = [
			"client_id=%s" % Credentials.CLIENT_ID,
			"redirect_uri=%s" % redirect_uri,
			"response_type=code",
			"scope=https://www.googleapis.com/auth/userinfo.profile",
		]
		
		var url :String = Credentials.AUTH_SERVER + "?" + "&".join(PackedStringArray(body_parts))
		
		if android_webview_popup_plugin != null:
			android_webview_popup_plugin.OpenUrl(url)
		
	# for else
	# open browser
	else:
		set_process(true)
		
		if not redirect_server.is_listening():
			redirect_server.listen(Credentials.PORT, Credentials.LOCAL_BINDING)
			
		var body_parts :Array = [
			"client_id=%s" % Credentials.CLIENT_ID,
			"redirect_uri=%s" % redirect_uri,
			"response_type=code",
			"scope=https://www.googleapis.com/auth/userinfo.profile",
		]
		
		var url :String = Credentials.AUTH_SERVER + "?" + "&".join(PackedStringArray(body_parts))
		OS.shell_open(url)
		
		
func _revoke_auth_code():
	if token == null:
		return
		
	var headers = PackedStringArray([
		"Content-Type: application/x-www-form-urlencoded",
	])
	
	var url :String = Credentials.TOKEN_REVOKE_SERVER + "?token=%s" % token
	var error = http_request_revoke_token_from_auth.request(
		url, headers, HTTPClient.METHOD_POST, ""
	)
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
		return
		
	var response :Array = await http_request_revoke_token_from_auth.request_completed
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return
		
	_delete_tokens()
	emit_signal("sign_out_completed")
	
func _refresh_tokens() -> bool:
	if refresh_token == null:
		return false
		
	var headers = PackedStringArray([
		"Content-Type: application/x-www-form-urlencoded",
	])
	
	var body_parts = PackedStringArray([
		"client_id=%s" % Credentials.CLIENT_ID,
		"client_secret=%s" % Credentials.CLIENT_ID,
		"refresh_token=%s" % refresh_token,
		"grant_type=refresh_token"
	])
	var body = "&".join(body_parts)
	
	var error = http_request_refresh_tokens.request(
		Credentials.TOKEN_REQ_SERVER, headers, HTTPClient.METHOD_POST, body
	)
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
		return false
	
	var response :Array = await http_request_refresh_tokens.request_completed
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return false
	
	var response_body :Dictionary = JSON.parse_string((response[3] as PackedByteArray).get_string_from_utf8())
	
	if response_body.has("access_token"):
		token = response_body["access_token"]
		_save_tokens()
		return true
		
	else:
		return false
		
func _is_token_valid() -> bool:
	if token == null:
		return false
	
	var headers = PackedStringArray([
		"Content-Type: application/x-www-form-urlencoded"
	])
	
	var body = "access_token=%s" % token
	
	var error = http_request_validate_tokens.request(
		Credentials.TOKEN_REQ_SERVER + "info", headers, HTTPClient.METHOD_POST, body
	)
	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
		return false
	
	var response :Array = await http_request_validate_tokens.request_completed
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return false
	
	var response_body :Dictionary = JSON.parse_string((response[3] as PackedByteArray).get_string_from_utf8())
	
	if response_body.has("expires_in"):
		var expiration = response_body["expires_in"]
		if int(expiration) > 0:
			return true
	else:
		return false
		
	return false
	
func get_profile_info():
	if token == null:
		return
		
	var request_url := "https://www.googleapis.com/oauth2/v1/userinfo?alt=json"
	var headers := [
		"Authorization: Bearer %s" % token,
		"Accept: application/json"
	]
	
	var error = http_request_profile_info.request(request_url, PackedStringArray(headers))
	if error != OK:
		push_error("ERROR OCCURED @ FUNC get_LiveBroadcastResource() : %s" % error)
		return
	
	var response :Array = await http_request_profile_info.request_completed
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return
	
	var response_body :Dictionary = JSON.parse_string((response[3] as PackedByteArray).get_string_from_utf8())
	
	emit_signal("get_profile", OAuth2UserInfo.new(response_body))
	
# SAVE/LOAD
const SAVE_PATH = 'user://token.dat'

func _save_tokens():
	# var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, Credentials.FILE_PASSWORD)
	if file == null:
		return
		
	var tokens :Dictionary = {}
	
	if redirect_code != null:
		tokens["redirect_code"] = redirect_code
		
	if tokens != null:
		tokens["token"] = token
		
	if refresh_token != null:
		tokens["refresh_token"] = refresh_token
		
	file.store_var(tokens)
	file.close()
		
func _load_tokens():
	token = null
	refresh_token = null
	
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	# var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, Credentials.FILE_PASSWORD)
	if file == null:
		return
		
	var tokens = file.get_var()
	if tokens == null:
		return
		
	if tokens.has("redirect_code"):
		redirect_code = tokens.get("redirect_code")
		
	if tokens.has("token"):
		token = tokens.get("token")
		
	if tokens.has("refresh_token"):
		refresh_token = tokens.get("refresh_token")
		
	file.close()
	
	
func _delete_tokens():
	token = null
	refresh_token = null
	redirect_code = null
	
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	DirAccess.remove_absolute(SAVE_PATH)
	
func _load_HTML(path :String) -> String:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var HTML = file.get_as_text().replace("    ", "\t").insert(0, "\n")
		file.close()
		return HTML
		
	return ""
	

class OAuth2UserInfo:
#	{
#	  "id": "106485650054118962173",
#	  "name": "Reno “Renosyah” Syahputra",
#	  "given_name": "Reno",
#	  "family_name": "Syahputra",
#	  "picture": "https://lh3.googleusercontent.com/a/AGNmyxbHss9Kn8mfyqqtP3iVQhtRxHKm5_4D4C1Uc3T1=s96-c",
#	  "locale": "id"
#	}

	var id :String
	var full_name :String
	var given_name :String
	var family_name :String
	var picture :String
	var locale :String

	func _init(_response :Dictionary):
		self.id = _response["id"]
		self.full_name  = _response["name"]
		self.given_name  = _response["given_name"]
		self.family_name = _response["family_name"]
		self.picture = _response["picture"]
		self.locale = _response["locale"]













