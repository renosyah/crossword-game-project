extends Control
class_name Banner

const banner_item = preload("res://assets/ui/banner/banner_item/banner_item.tscn")
const base_url :String = "http://192.168.1.78:8080"

@onready var _url_banners :String = "%s/api/banner/list.php" % base_url
@onready var _is_web :bool = "Web" == OS.get_name()
@onready var _http_request = $HTTPRequest

@onready var _scroll_container = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer/ScrollContainer
@onready var _h_box_container = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer/ScrollContainer/HBoxContainer
@onready var _button_title = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer2/close/CenterContainer/button_title

var _banners :Array = []

func _ready():
	_button_title.text = tr("CLOSE")

func request_banners():
	if _is_web:
		_http_request.accept_gzip = false
		
	var body :Dictionary = {
		"search_by": "banner_name",
		"search_value": "",
		"order_by": "id",
		"order_dir": "asc",
		"offset": 0,
		"limit": 10
	}
	var error = _http_request.request(
		_url_banners, [], HTTPClient.METHOD_POST, JSON.stringify(body)
	)
	if error != OK:
		return

func _on_http_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
		
	if json["data"] == null:
		return
		
	var datas :Array = json["data"] as Array
	_banners.clear()
	
	for i in datas:
		_banners.append(BannerData.new(i))
		
	_display_banner()
	
func _display_banner():
	for i in _h_box_container.get_children():
		_h_box_container.remove_child(i)
		i.queue_free()
	
	await get_tree().process_frame
	
	var _scroll_container_size = _scroll_container.size
	
	for i in _banners:
		var item :BannerData = i
		var banner :BannerItem = banner_item.instantiate()
		banner.image_url = item.banner_image_url
		banner.custom_minimum_size = _scroll_container_size
		_h_box_container.add_child(banner)
	
func _on_v_box_container_resized():
	if not is_instance_valid(_h_box_container):
		return
		
	if not is_instance_valid(_scroll_container):
		return
		
	var _scroll_container_size = _scroll_container.size
	
	for i in _h_box_container.get_children():
		i.custom_minimum_size = _scroll_container_size
		
func _on_close_pressed():
	visible = false
	
class BannerData:
	var id :int
	var banner_name :String
	var banner_image_url :String
	
	func _init(_data :Dictionary):
		self.id = _data["id"]
		self.banner_name = _data["banner_name"]
		self.banner_image_url = _data["banner_image_url"]





















