extends Node
class_name CurrentTime

signal current_time(time)
signal error(msg)

var _http_request :HTTPRequest
var _current_time: Dictionary

func _ready():
	_http_request = HTTPRequest.new()
	_http_request.request_completed.connect(_on_request_global_current_time)
	add_child(_http_request)
	
func request_current_time():
	var error = _http_request.request("https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta")
	if error != OK:
		emit_signal("error", "failed request time!")
	
func _on_request_global_current_time(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("error", "failed request time!")
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	_current_time = {
		"year":json["year"],
		"month":json["month"],
		"day":json["day"],
		"hour":json["hour"],
		"minute":json["minute"],
		"second":json["seconds"]
	}
	
	emit_signal("current_time", _current_time)
