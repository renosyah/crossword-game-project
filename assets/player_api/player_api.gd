extends Node
class_name PlayerApi

signal add(ok)
signal get_one(ok, player)
signal update(ok)

const base_url :String = "http://192.168.1.78:8080"

@onready var _url_add_player :String = "%s/api/player/add.php" % base_url
@onready var _url_one_player :String = "%s/api/player/one.php" % base_url
@onready var _url_update_player :String = "%s/api/player/update.php" % base_url
@onready var _is_web :bool = "Web" == OS.get_name()

var _http_request_add_player :HTTPRequest
var _http_request_one_player :HTTPRequest
var _http_request_update_player :HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	_http_request_add_player = HTTPRequest.new()
	_http_request_add_player.request_completed.connect(_on_request_add_player_completed)
	add_child(_http_request_add_player)
	
	_http_request_one_player = HTTPRequest.new()
	_http_request_one_player.request_completed.connect(_on_request_one_player_completed)
	add_child(_http_request_one_player)
	
	_http_request_update_player = HTTPRequest.new()
	_http_request_update_player.request_completed.connect(_on_request_update_player_completed)
	add_child(_http_request_update_player)
	
	
func request_add_player(_player :Player):
	if _is_web:
		_http_request_add_player.accept_gzip = false
		
	var error = _http_request_add_player.request(
		_url_add_player, [], HTTPClient.METHOD_POST, JSON.stringify(_player.to_dict())
	)
	if error != OK:
		emit_signal("add", false)
		return
	
func _on_request_add_player_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("add", false)
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("add", false)
		return
		
	if json["data"] == null:
		emit_signal("add", false)
		return
		
	emit_signal("add", true)
	
func request_one_player(player_id :String):
	if _is_web:
		_http_request_one_player.accept_gzip = false
		
	var player :Dictionary = {
		"id": 0,
		"player_id": player_id,
		"player_name": "",
		"player_email": "",
		"player_avatar": "",
		"save_data_json": ""
	}
	var error = _http_request_one_player.request(
		_url_one_player, [], HTTPClient.METHOD_POST, JSON.stringify(player)
	)
	if error != OK:
		emit_signal("get_one", false, null)
		return
	
	
func _on_request_one_player_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("get_one", false, null)
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("get_one", false, null)
		return
		
	if json["data"] == null:
		emit_signal("get_one", false, null)
		return
		
	emit_signal("get_one", true, Player.new(json["data"]))
	
	
func request_update_player(_player :Player):
	if _is_web:
		_http_request_update_player.accept_gzip = false
		
	var error = _http_request_update_player.request(
		_url_update_player, [], HTTPClient.METHOD_POST, JSON.stringify(_player.to_dict())
	)
	if error != OK:
		emit_signal("update", false)
		return
		
func _on_request_update_player_completed(result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("update", false)
		return
		
	emit_signal("update", true)
	
	
class Player:
	var id :int
	var player_id :String
	var player_name :String
	var player_email :String
	var player_avatar :String
	var save_data_json :String
	
	func _init(_data : Dictionary):
		self.id = _data["id"]
		self.player_id = _data["player_id"]
		self.player_name = _data["player_name"]
		self.player_email = _data["player_email"]
		self.player_avatar = _data["player_avatar"]
		self.save_data_json = _data["save_data_json"]
		
	func to_dict() -> Dictionary:
		var data : Dictionary = {}
		data["id"] = id
		data["player_id"] = player_id
		data["player_name"] = player_name
		data["player_email"] = player_email
		data["player_avatar"] = player_avatar
		data["save_data_json"] = save_data_json
		return data
		
