extends Control

const item_scene = preload("res://assets/ui/level_displayer/level_item/level_item.tscn")
const prize_scene = preload("res://assets/ui/level_displayer/prize_item/prize_item.tscn")

@onready var holder_container = $HBoxContainer/ScrollContainer/VBoxContainer/VBoxContainer
@onready var scroll_container = $HBoxContainer/ScrollContainer
@onready var banners_holder = $banners
@onready var http_request = $HTTPRequest
@onready var _is_web :bool = "Web" == OS.get_name()

var offset = 0
var limit = 50
var banner_pos = 5

var prizes :Array = []
var banners :Array = []

func _ready():
	Global.prize_api.prizes.connect(_on_prizes)
	Global.prize_api.request_prizes(0, 100)
	request_banners()
	
func _on_prizes(ok :bool, datas :Array):
	prizes = datas
	
func display_level():
	clear_all()
	limit = Global.level + limit
	_display_level()
	
func clear_all():
	offset = 0
	banner_pos = 5
	
	for i in holder_container.get_children():
		holder_container.remove_child(i)
		i.queue_free()
		
	for i in banners_holder.get_children():
		banners_holder.remove_child(i)
		i.queue_free()
		

func _display_level():
	var scroll_offset = 0
	
	for i in range(offset, offset + limit, 1):
		if i < 0:
			continue
			
		var level = i + 1
		var item = item_scene.instantiate()
		item.level = level
		item.is_locked = level > Global.level
		item.is_current = level == Global.level
		item.is_odd = level % 2 != 0
		item.show_dot = level > 1
		holder_container.add_child(item)
		holder_container.move_child(item, 0)
		
		if item.is_locked:
			scroll_offset += 90
			
		var prize : PrizeApi.Prize = _get_prize_by_level(level)
		if prize != null:
			var banner = prize_scene.instantiate()
			banner.prize_image_url = prize.prize_image_url
			banner.prize_name = prize.prize_name
			banner.is_odd = level % 2 != 0
			banner.follow = item.item
			banners_holder.add_child(banner)
			
		if banner_pos == level:
			banner_pos += 5
			
			if prize == null:
				var item_banner :Banner.BannerData = _get_random_banner()
				if item_banner != null:
					var banner = prize_scene.instantiate()
					banner.prize_image_url = item_banner.banner_image_url
					banner.is_odd = level % 2 != 0
					banner.follow = item.item
					banners_holder.add_child(banner)
		
	await get_tree().process_frame
	scroll_offset -= 300
	scroll_container.scroll_vertical = scroll_offset

func _on_visible_on_screen_notifier_2d_screen_entered():
	offset += limit
	_display_level()


func _get_prize_by_level(level :int) -> PrizeApi.Prize:
	for i in prizes:
		var item :PrizeApi.Prize = i
		if item.prize_level == level:
			return item
			
	return null
	
func _get_random_banner() -> Banner.BannerData:
	if banners.is_empty():
		return null
		
	return banners.pick_random()
	
	
func request_banners():
	if _is_web:
		http_request.accept_gzip = false
		
	var body :Dictionary = {
		"search_by": "banner_name",
		"search_value": "",
		"order_by": "id",
		"order_dir": "asc",
		"offset": 0,
		"limit": 100
	}
	var error = http_request.request(
		"%s/api/banner/list.php" % Global.server_host, [], HTTPClient.METHOD_POST, JSON.stringify(body)
	)
	if error != OK:
		return

func _on_http_request_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		return
		
	var json :Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
		
	if json["data"] == null:
		return
		
	var datas :Array = json["data"] as Array
	banners.clear()
	
	for i in datas:
		banners.append(Banner.BannerData.new(i))
		















