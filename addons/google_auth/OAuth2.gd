extends Node

signal sign_in_completed
signal sign_in_expired

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

var simple_delay :Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	is_web_app = ["Web"].has(OS.get_name())
	
	# because browser use broken as CORS stupid bitch
	# this will solve it
	if (is_web_app):
		http_request_token_from_auth.accept_gzip = false
		http_request_refresh_tokens.accept_gzip = false
		http_request_validate_tokens.accept_gzip = false
		http_request_profile_info.accept_gzip = false
		
	if ["Android"].has(OS.get_name()):
		is_android_app = true
		android_webview_popup_plugin = Engine.get_singleton("WebViewPopUp")
	
	add_child(http_request_token_from_auth)
	add_child(http_request_refresh_tokens)
	add_child(http_request_validate_tokens)
	add_child(http_request_profile_info)
	
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
			
			if is_android_app:
				android_webview_popup_plugin.ClosePopUp()
				
			var auth_code = request.split("&scope")[0].split("=")[1]
			_get_token_from_auth(auth_code)
			
			connection.put_data(("HTTP/1.1 %d\r\n" % 200).to_ascii_buffer())
			connection.put_data(load_HTML("res://addons/google_auth/display_page.csv").to_ascii_buffer())
			redirect_server.stop()
	
func _get_token_from_auth(auth_code :String):
	var headers = PackedStringArray([
		"Content-Type: application/x-www-form-urlencoded",
	])
	
	var body_parts :Array = [
		"code=%s" % auth_code, 
		"client_id=%s" % Credentials.CLIENT_ID,
		"client_secret=%s" % Credentials.WEB_CLIENT_SECRET,
		("redirect_uri=%s" % Credentials.WEB_REDIRECT_URL) if is_web_app else ("redirect_uri=%s" % redirect_uri),
		"grant_type=authorization_code"
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
		emit_signal("sign_in_expired")
		return
		
	var token_valid :bool = await _is_token_valid()
	if not token_valid:
		
		# try refresh if not valid
		if refresh_token == null:
			emit_signal("sign_in_expired")
			return
			
		var ok = await _refresh_tokens()
		if not ok:
			emit_signal("sign_in_expired")
			return
			
		
	emit_signal("sign_in_completed")

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
	var body_parts :Array
	var os :String = OS.get_name()
	
	var client_id :String = "client_id=%s" % Credentials.CLIENT_ID
	var scope :String = "scope=https://www.googleapis.com/auth/userinfo.profile"
	var response_type :String = "response_type=code"
	
	if is_web_app:
		body_parts = [
			client_id,
			"redirect_uri=%s" % Credentials.WEB_REDIRECT_URL,
			response_type,
			scope,
		]
		var url :String = Credentials.AUTH_SERVER + "?" + "&".join(PackedStringArray(body_parts))
		JavaScriptBridge.eval('window.location.replace("%s")' % url)
		return
		
	set_process(true)
	
	if not redirect_server.is_listening():
		redirect_server.listen(Credentials.PORT, Credentials.LOCAL_BINDING)
	
	body_parts = [
		client_id,
		"redirect_uri=%s" % redirect_uri,
		response_type,
		scope,
	]
	
	var url :String = Credentials.AUTH_SERVER + "?" + "&".join(PackedStringArray(body_parts))
	if is_android_app:
		android_webview_popup_plugin.OpenUrl(url)
		return
	
	OS.shell_open(url)

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
	
func get_profile_info() -> Dictionary:
	if token == null:
		return {}
		
	var request_url := "https://www.googleapis.com/oauth2/v1/userinfo?alt=json"
	var headers := [
		"Authorization: Bearer %s" % token,
		"Accept: application/json"
	]
	
	var error = http_request_profile_info.request(request_url, PackedStringArray(headers))
	if error != OK:
		push_error("ERROR OCCURED @ FUNC get_LiveBroadcastResource() : %s" % error)
		return {}
	
	var response :Array = await http_request_profile_info.request_completed
	if response[0] != HTTPRequest.RESULT_SUCCESS:
		return {}
	
	var response_body :Dictionary = JSON.parse_string((response[3] as PackedByteArray).get_string_from_utf8())
	
	return response_body
	
# SAVE/LOAD
const SAVE_PATH = 'user://token.dat'

func _save_tokens():
	#var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, Credentials.FILE_PASSWORD)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
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
		
	#var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, Credentials.FILE_PASSWORD)
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
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
	
	
func load_HTML(path :String) -> String:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var HTML = file.get_as_text().replace("    ", "\t").insert(0, "\n")
		file.close()
		return HTML
		
	return ""
	















