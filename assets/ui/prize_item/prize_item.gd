extends MarginContainer
class_name PrizeItem

signal redeem(_id, _name)

@export var id :int
@export var prize_name :String
@export var prize_image_url :String
@export var prize_level :int

@export var can_redeem :bool

@onready var _prize_name = $Panel/HBoxContainer/VBoxContainer/prize_name
@onready var _level = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/level
@onready var _button_redeem_label = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/redeem/CenterContainer/Label
@onready var _texture_rect = $Panel/HBoxContainer/Control/TextureRect
@onready var _redeem_button = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/redeem
@onready var _http_request = $HTTPRequest

@onready var _panel_style :StyleBoxFlat = $Panel.get_theme_stylebox(StringName("panel")).duplicate()
@onready var _panel = $Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	_panel.remove_theme_stylebox_override("panel")
	_panel.add_theme_stylebox_override("panel", _panel_style)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = id
	
	_panel_style.bg_color = Color(rng.randf(), rng.randf(), rng.randf(), 1.0)
	_redeem_button.modulate.a = 1.0 if can_redeem else 0.5
	
	_prize_name.text = prize_name
	_level.text = "%s %s" % [tr("LEVEL") ,prize_level]
	_button_redeem_label.text = tr("REDEEM")
	
	if prize_image_url.is_empty():
		return
		
	if "Web" == OS.get_name():
		_http_request.accept_gzip = false
		
	var error = _http_request.request(prize_image_url)
	if error != OK:
		return
	
func _on_redeem_pressed():
	if not can_redeem:
		return
		
	emit_signal("redeem", id, prize_name)
	
func _on_http_request_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
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

