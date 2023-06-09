extends Node
class_name RegenerateItemHandler

signal regenerate_complete
signal one_second_pass

var _timer :Timer
var _current_time :dateTime
var _valid :bool = false

@export var item_name :String
@export var item_count :int = 10
@export var item_max :int = 10

@export var cooldown :int = 30 # in second

# array of object
var regenerating_items :Array = []

func _ready():
	_timer = Timer.new()
	_timer.autostart = false
	_timer.one_shot = true
	_timer.wait_time = 1
	_timer.timeout.connect(_on_one_sec_pass)
	
	add_child(_timer)
	
func is_valid() -> bool:
	return _valid
	
func run_regenerating(_current_time_dict :Dictionary):
	if _current_time_dict.is_empty():
		return
		
	_current_time = dateTime.new(_current_time_dict)
	_valid = true
	_load_last_data()
	_timer.start()
	
func _save_data():
	# remove garbage
	_clear_done()
	
	var regenerating_items_datas :Array = []
	
	for i in regenerating_items:
		var _item :regenerateItem = i
		regenerating_items_datas.append(i.to_dict())
		
	SaveLoad.save("%s_regenerating_items_datas.data" % item_name, regenerating_items_datas)
	
func _load_last_data():
	regenerating_items.clear()
	
	var regenerating_items_datas = SaveLoad.load_save("%s_regenerating_items_datas.data" % item_name)
	
	if regenerating_items_datas != null:
		for i in (regenerating_items_datas as Array):
			var item = regenerateItem.new()
			item.from_dict(i)
			item.current_time = _current_time.copy()
			regenerating_items.append(item)
			item_count -= 1
	
func add_generate_item(count :int = 1):
	if item_count <= 0 or not _valid:
		return
		
	if item_count - count < 0:
		return
		
	# add more cooldown currently in regenerate proccess
	for i in regenerating_items:
		var item :regenerateItem = i
		item.end_time.add(cooldown)
		
	item_count = clamp(item_count - 1, 0, item_max)
		
	_timer.stop()
		
	for i in count:
		var item = regenerateItem.new()
		item.item_name = item_name
		item.is_regenerating = true
		item.start_time = _current_time.copy()
		item.end_time = _current_time.copy().add(cooldown)
		item.current_time = _current_time.copy()
		regenerating_items.append(item)
		
	_save_data()
	_timer.start()
	
func remove_generate_item(count :int = 1):
	if not _valid:
		return
		
	if regenerating_items.is_empty():
		return
		
	_timer.stop()
	
	# remove garbage
	_clear_done()
	
	for _i in count:
		var item_remove :regenerateItem = regenerating_items[0]
		for i in regenerating_items:
			if i.get_remaining() < item_remove.get_remaining():
				item_remove = i
			
		regenerating_items.erase(item_remove)
		item_count = clamp(item_count + 1, 0, item_max)
		
		for i in regenerating_items:
			var item :regenerateItem = i
			item.end_time.add(-cooldown)
		
	_save_data()
	_timer.start()
	
	
func _clear_done():
	var _holders :Array = []
	
	for i in regenerating_items:
		var item :regenerateItem = i
		if item.is_regenerating:
			_holders.append(i)
		
	regenerating_items.clear()
	regenerating_items.append_array(_holders)
	
func _on_one_sec_pass():
	_timer.start()
	
	var signal_emmited :bool = false
	
	# update current time 1 second
	_current_time.add(1)
	
	# remove garbage
	_clear_done()
	
	for i in regenerating_items:
		var item :regenerateItem = i
		if not item.is_regenerating:
			continue
			
		item.current_time = _current_time.copy()
		
		if item.get_remaining() < 0:
			item.is_regenerating = false
			item_count = clamp(item_count + 1, 0, item_max)
			signal_emmited = true
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
		
	func to_dict() -> Dictionary:
		return {
			"item_name" : item_name,
			"is_regenerating" : is_regenerating,
			"start_time" : start_time.to_dict(),
			"end_time" : end_time.to_dict(),
		}
		
	func from_dict(_dict :Dictionary):
		item_name = _dict["item_name"]
		is_regenerating = _dict["is_regenerating"]
		start_time = dateTime.new(_dict["start_time"])
		end_time = dateTime.new(_dict["end_time"])
		
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
		
	func add(_second :int) -> dateTime:
		var _current_update_time :int = Time.get_unix_time_from_datetime_dict(to_dict())
		_current_update_time += _second
		_init(Time.get_datetime_dict_from_unix_time(_current_update_time))
		return self
	
	func get_minute_second() -> String:
		return "%s:%s" % [minute, second]

