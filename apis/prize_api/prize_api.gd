extends Node
class_name PrizeApi

signal check_redeem(ok,exist)
signal prizes(ok,datas)
signal redeemed(ok)

@export var server_host :String
@export var max_timeout :int

@onready var _url_redeem :String = "%s/api/redeem/add.php" % server_host
@onready var _url_prizes :String = "%s/api/prize/list.php" % server_host
@onready var _url_check_redeem :String = "%s/api/redeem/one_exist.php" % server_host
@onready var _is_web :bool = "Web" == OS.get_name()

var _http_request_redeem :HTTPRequest
var _http_request_get_prizes :HTTPRequest
var _http_request_check_redeem :HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	_http_request_redeem = HTTPRequest.new()
	_http_request_redeem.timeout = max_timeout
	_http_request_redeem.request_completed.connect(_on_request_redeem_completed)
	add_child(_http_request_redeem)
	
	_http_request_get_prizes = HTTPRequest.new()
	_http_request_get_prizes.timeout = max_timeout
	_http_request_get_prizes.request_completed.connect(_on_request_get_prizes_completed)
	add_child(_http_request_get_prizes)
	
	_http_request_check_redeem = HTTPRequest.new()
	_http_request_check_redeem.timeout = max_timeout
	_http_request_check_redeem.request_completed.connect(_on_request_check_redeem_completed)
	add_child(_http_request_check_redeem)
	
func redeem_prizes(player_id :int, prize_id :int):
	if _is_web:
		_http_request_redeem.accept_gzip = false
		
	var data :Dictionary = {
		"id": 0,
		"player_id": player_id,
		"prize_id": prize_id
	}
	var error = _http_request_redeem.request(
		_url_redeem, [], HTTPClient.METHOD_POST, JSON.stringify(data)
	)
	if error != OK:
		emit_signal("redeemed", false)
		return
	
func _on_request_redeem_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("redeemed", false)
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("redeemed", false)
		return
		
	if json["data"] == null:
		emit_signal("redeemed", false)
		return
		
	emit_signal("redeemed", true)
	
	
func request_prizes(offset :int, limit :int):
	if _is_web:
		_http_request_get_prizes.accept_gzip = false
		
	var body :Dictionary = {
		"search_by": "prize_name",
		"search_value": "",
		"order_by": "prize_level",
		"order_dir": "desc",
		"offset": offset,
		"limit": limit
	}
	var error = _http_request_get_prizes.request(
		_url_prizes, [], HTTPClient.METHOD_POST, JSON.stringify(body)
	)
	if error != OK:
		emit_signal("prizes", false, null)
		return
	
func _on_request_get_prizes_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("prizes", false, null)
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("prizes", false, null)
		return
		
	if json["data"] == null:
		emit_signal("prizes", false, null)
		return
	
	var datas :Array = []
	for i in json["data"]:
		datas.append(Prize.new(i))
		
	emit_signal("prizes", true, datas)
	
func request_check_redeem(player_id :int, prize_id :int):
	if _is_web:
		_http_request_check_redeem.accept_gzip = false
		
	var body :Dictionary = {
		"id": 0,
		"prize_id": prize_id,
		"player_id": player_id,
	}
	var error = _http_request_check_redeem.request(
		_url_check_redeem, [], HTTPClient.METHOD_POST, JSON.stringify(body)
	)
	if error != OK:
		emit_signal("check_redeem", false, false)
		return
	
func _on_request_check_redeem_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("check_redeem", false, false)
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("check_redeem", true, false)
		return
		
	if json["data"] == null:
		emit_signal("check_redeem", true, false)
		return
		
	emit_signal("check_redeem", true, true)
	
class Prize:
	var id :int
	var prize_name :String
	var prize_image_url :String
	var prize_level :int
	
	func _init(_data :Dictionary):
		self.id = _data["id"]
		self.prize_name = _data["prize_name"]
		self.prize_image_url = _data["prize_image_url"]
		self.prize_level = _data["prize_level"]















