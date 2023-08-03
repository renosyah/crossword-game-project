extends Control

@export var prize_image_url :String
@export var prize_name :String
@export var is_odd :bool
@export var follow :Control

@onready var _h_box_container = $HBoxContainer
@onready var _texture_rect = $HBoxContainer/pos/MarginContainer/Panel/TextureRect
@onready var _http_request = $HTTPRequest
@onready var _prize_name = $HBoxContainer/pos/MarginContainer/Panel/prize_name

func _ready():
	_prize_name.visible = not prize_name.is_empty()
	_prize_name.text = prize_name
	
	if is_odd:
		_h_box_container.alignment = HBoxContainer.ALIGNMENT_BEGIN
		
	else:
		_h_box_container.alignment = HBoxContainer.ALIGNMENT_END
		
		
	if "Web" == OS.get_name():
		_http_request.accept_gzip = false
		
	var error = _http_request.request(prize_image_url)
	if error != OK:
		return
		
func _process(delta):
	if not is_instance_valid(follow):
		set_process(false)
		queue_free()
		return
		
	position = follow.get_global_rect().position
	
func _on_http_request_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		return
		
	if body.is_empty():
		return null
		
	var img = _check_image_format(body)
	if img == null:
		return null
		
	_texture_rect.texture = ImageTexture.create_from_image(img)
	
func _check_image_format(body :PackedByteArray) -> Image:
	var img = Image.new()
	
	var image_error = img.load_png_from_buffer(body)
	if image_error == OK:
		return img
		
	image_error = img.load_jpg_from_buffer(body)
	if image_error == OK:
		return img
		
	image_error = img.load_bmp_from_buffer(body)
	if image_error == OK:
		return img
		
	return null
