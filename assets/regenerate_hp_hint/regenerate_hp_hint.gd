extends Node
class_name RegenerateHpHint

signal error
signal ready_to_regenerate
signal regenerate_complete
signal one_second_pass

var _current_time: dateTime
var _http_request :HTTPRequest
var _timer :Timer

@export var player_hint :int = 10
@export var player_max_hint :int = 10

@export var player_hp :int = 5
@export var player_max_hp :int = 5

@export var cooldown :int = 30 # in second

var hp_regenerating :Array = []
var hint_regenerating :Array = []

func _ready():
	_current_time = dateTime.new(Time.get_datetime_dict_from_system())
	
	_http_request = HTTPRequest.new()
	_http_request.request_completed.connect(_on_request_global_current_time)
	
	_timer = Timer.new()
	_timer.autostart = false
	_timer.one_shot = true
	_timer.wait_time = 1
	_timer.timeout.connect(_on_one_sec_pass)
	
	add_child(_http_request)
	add_child(_timer)
	
	await get_tree().process_frame
	
	var error = _http_request.request("https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta")
	if error != OK:
		emit_signal("error", "failed request time!")
		return
	
func add_generate_item(item_name :String, count :int = 1):
	# add more cooldown currently in regenerate proccess
	if item_name == "hp":
		for i in hp_regenerating:
			var item :regenerateItem = i
			item.end_time.add(cooldown)
			
	elif item_name == "hint":
		for i in hint_regenerating:
			var item :regenerateItem = i
			item.end_time.add(cooldown)
			
	for i in count:
		var item = regenerateItem.new()
		item.item_name = item_name
		item.is_regenerating = true
		item.start_time = _current_time.copy()
		item.end_time = _current_time.copy().add(cooldown)
		item.current_time = _current_time.copy()
		
		if item_name == "hp":
			player_hp -= 1
			hp_regenerating.append(item)
			
		elif item_name == "hint":
			player_hint -= 1
			hint_regenerating.append(item)
	
func _clear_done(_items :Array):
	var clear_done_pos :Array = []
	
	for i in _items.size():
		var item :regenerateItem = _items[i]
		if not item.is_regenerating:
			clear_done_pos.append(i)
			
	for i in clear_done_pos:
		_items.remove_at(i)
		
func _on_request_global_current_time(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("error", "failed request time!")
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	_current_time = dateTime.new({"year":json["year"],"month":json["month"],"day":json["day"],"hour":json["hour"],"minute":json["minute"],"second":json["seconds"]})
	
	emit_signal("ready_to_regenerate")
	_timer.start()
	
func _on_one_sec_pass():
	_timer.start()
	
	var signal_emmited :bool = false
	
	# update current time 1 second
	_current_time.add(1)
	
	# remove garbage
	_clear_done(hp_regenerating)
	_clear_done(hint_regenerating)
	
	var arrays :Array = (hp_regenerating + hint_regenerating)
	for i in arrays:
		var item :regenerateItem = i
		if not item.is_regenerating:
			continue
			
		item.current_time = _current_time.copy()
		
		if item.get_remaining() < 0:
			item.is_regenerating = false
			if item.item_name == "hp":
				player_hp = clamp(player_hp + 1, 0, player_max_hp)
				signal_emmited = true
				emit_signal("regenerate_complete")
				
			elif item.item_name == "hint":
				signal_emmited = true
				player_hint = clamp(player_hint + 1, 0, player_max_hint)
				emit_signal("regenerate_complete")
				
	if not signal_emmited:
		emit_signal("one_second_pass")
		
# classes
class regenerateItem:
	var item_name :String
	var is_regenerating :bool
	var start_time :dateTime
	var end_time :dateTime
	var current_time :dateTime
	
	func get_remaining() -> int:
		var diff = (end_time.get_unix() - current_time.get_unix())
		#var result = Time.get_datetime_dict_from_unix_time()
		#return "{minute}:{second}".format(result)
		return diff
		
	func get_total() -> int:
		var diff = (end_time.get_unix() - start_time.get_unix())
		#var result = Time.get_datetime_dict_from_unix_time(diff)
		#return "{minute}:{second}".format(result)
		return diff
		
class dateTime:
	var year :int
	var month :int
	var day :int
	var hour :int
	var minute :int
	var second:int
	
	func _init(_date_time :Dictionary):
		self.year = _date_time["year"]
		self.month = _date_time["month"]
		self.day = _date_time["day"]
		self.hour = _date_time["hour"]
		self.minute = _date_time["minute"]
		self.second = _date_time["second"]
		
	func to_dict() -> Dictionary:
		return {"year":year,"month":month,"day":day,"hour":hour,"minute":minute,"second":second}
		
	func copy() -> dateTime:
		return dateTime.new(to_dict())
		
	func get_unix() -> int:
		return Time.get_unix_time_from_datetime_dict(to_dict())
		
	func add(second :int) -> dateTime:
		var _current_update_time :int = Time.get_unix_time_from_datetime_dict(to_dict())
		_current_update_time += second
		_init(Time.get_datetime_dict_from_unix_time(_current_update_time))
		return self
	
	func get_minute_second() -> String:
		return "%s:%s" % [minute, second]

