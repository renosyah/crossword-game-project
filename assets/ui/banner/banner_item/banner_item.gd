extends MarginContainer
class_name BannerItem

@export var image_url :String

@onready var _texture_rect = $TextureRect
@onready var _loading = $loading
@onready var _http_request = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	_loading.visible = true
	
	if image_url.is_empty():
		return
		
	if "Web" == OS.get_name():
		_http_request.accept_gzip = false
		
	var error = _http_request.request(image_url)
	if error != OK:
		return
		
func _on_http_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		return
		
	if body.is_empty():
		return null
		
	var img = _check_image_format(body)
	if img == null:
		return null
		
	_texture_rect.texture = ImageTexture.create_from_image(img)
	_loading.visible = false
	
func _check_image_format(body :PackedByteArray) -> Image:
	var img = Image.new()
	
	var image_error = img.load_jpg_from_buffer(body)
	if image_error == OK:
		return img
		
	image_error = img.load_png_from_buffer(body)
	if image_error == OK:
		return img
		
	image_error = img.load_bmp_from_buffer(body)
	if image_error == OK:
		return img
		
	return null





