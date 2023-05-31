extends MarginContainer
class_name RankItem

var number :int
var level :int
var player :PlayerData

@onready var num = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/num
@onready var avatar = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/MarginContainer/avatar
@onready var player_name = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/player_name
@onready var player_level = $HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer/player_level
@onready var http_request = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	num.text = "%s." % number
	player_name.text = player.player_name
	player_level.text = "Level %s" % level
	
	get_avatar_image()
	
func get_avatar_image():
	if player.player_avatar.is_empty():
		return
		
	var http_error = http_request.request(player.player_avatar)
	if http_error != OK:
		return
		
func _on_http_request_request_completed(result, response_code, headers, body :PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		return
		
	var img = Image.new()
	var image_error = img.load_jpg_from_buffer(body)
	if image_error != OK:
		return
		
	avatar.texture = ImageTexture.create_from_image(img)
	







