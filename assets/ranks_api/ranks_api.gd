extends Node
class_name RanksApi

signal one_rank(ok, data)
signal rank_added(ok)
signal ranks(ok, datas)

@export var server_host :String

@onready var _url_one_rank :String = "%s/api/rank/one_player.php" % server_host
@onready var _url_add_ranks :String = "%s/api/rank/add.php" % server_host
@onready var _url_ranks :String = "%s/api/rank/list.php" % server_host
@onready var _is_web :bool = "Web" == OS.get_name()

var _http_request_ranks :HTTPRequest
var _http_request_one_rank :HTTPRequest
var _http_request_add_rank :HTTPRequest
var _datas :Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_http_request_ranks = HTTPRequest.new()
	_http_request_ranks.request_completed.connect(_on_request_ranks_completed)
	add_child(_http_request_ranks)
	
	_http_request_one_rank = HTTPRequest.new()
	_http_request_one_rank.request_completed.connect(_on_request_one_rank_completed)
	add_child(_http_request_one_rank)
	
	_http_request_add_rank = HTTPRequest.new()
	_http_request_add_rank.request_completed.connect(_on_request_add_ranks_completed)
	add_child(_http_request_add_rank)
	
func request_list_ranks(offset :int, limit :int = 10):
	if _is_web:
		_http_request_ranks.accept_gzip = false
		
	var body :Dictionary = {
		"search_by": "player_name",
		"search_value": "",
		"order_by": "rank_level",
		"order_dir": "desc",
		"offset": offset,
		"limit": limit
	}
	var error = _http_request_ranks.request(
		_url_ranks, [], HTTPClient.METHOD_POST, JSON.stringify(body)
	)
	if error != OK:
		emit_signal("ranks", false, _datas)
		return
	
func _on_request_ranks_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("ranks", false, _datas)
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("ranks", false, _datas)
		return
		
	if json["data"] == null:
		emit_signal("ranks", false, _datas)
		return
		
	var datas :Array = json["data"] as Array
	
	_datas.clear()
	
	for i in datas:
		var item :Rank = Rank.new(i)
		_datas.append(item)
		
	emit_signal("ranks", true, _datas)
	
	
func request_add_ranks(_rank :Rank):
	if _is_web:
		_http_request_add_rank.accept_gzip = false
		
	var error = _http_request_add_rank.request(
		_url_add_ranks, [], HTTPClient.METHOD_POST, JSON.stringify(_rank.to_dict())
	)
	if error != OK:
		emit_signal("rank_added", false)
		return
		
func _on_request_add_ranks_completed(result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("rank_added", false)
		return
		
	emit_signal("rank_added", true)
	
	
func request_one_rank(_player_id :String):
	var _rank :Rank = Rank.new({
		"id": 0,
		"player_id": _player_id,
		"player_name": "",
		"player_email": "",
		"player_avatar" : "",
		"rank_level" : "",
	})
	
	if _is_web:
		_http_request_one_rank.accept_gzip = false
		
	var error = _http_request_one_rank.request(
		_url_one_rank, [], HTTPClient.METHOD_POST, JSON.stringify(_rank.to_dict())
	)
	if error != OK:
		emit_signal("one_rank", false, null)
		return
	
func _on_request_one_rank_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("one_rank", false, null)
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("one_rank", false, null)
		return
		
	if json["data"] == null:
		emit_signal("one_rank", false, null)
		return
		
	var data :Dictionary= json["data"] as Dictionary
	emit_signal("one_rank", true, Rank.new(data))
	
class Rank:
	var id :int
	var player_id :String
	var player_name :String
	var player_email :String
	var player_avatar :String
	var rank_level :int
	
	# optional
	var number :int
	
	func _init(_data :Dictionary):
		self.id = _data["id"]
		self.player_id = _data["player_id"]
		self.player_name = _data["player_name"]
		self.player_email = _data["player_email"]
		self.player_avatar = _data["player_avatar"]
		self.rank_level = _data["rank_level"]
		
		if _data.has("number"):
			self.number = _data["number"]
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"player_id": player_id,
			"player_name": player_name,
			"player_email": player_email,
			"player_avatar" : player_avatar,
			"rank_level" : rank_level
		}
























