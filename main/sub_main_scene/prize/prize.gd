extends Control

signal back
signal error

@onready var player_prize_redeem = $VBoxContainer/player_prize_redeem
@onready var label = $VBoxContainer/HBoxContainer2/Label
@onready var v_box_container = $VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer
@onready var loading = $loading
@onready var animation_player = $AnimationPlayer

var _player :PlayerApi.Player = null
var _player_rank_level :int = 0

@onready var label_player_name = $VBoxContainer/player_prize_redeem/VBoxContainer/label_player_name
@onready var label_player_level = $VBoxContainer/player_prize_redeem/VBoxContainer/label_player_level
@onready var player_avatar = $VBoxContainer/player_prize_redeem/MarginContainer/Panel2/player_avatar

@onready var redeem_prize_dialog = $redeem_prize

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = tr("PRIZE")
	player_prize_redeem.visible = false
	
	loading.visible = true
	redeem_prize_dialog.visible = false
	
	Global.rank_api.one_rank.connect(_one_rank)
	Global.prize_api.prizes.connect(_on_prizes)
	
func show_prize():
	animation_player.play("RESET")
	loading.visible = true
	_remove_child(v_box_container)
	
	# request player data
	if _player == null:
		Global.player_api.request_one_player(Global.player.player_id)
		var result :Array = await Global.player_api.get_one
		if not result[0]:
			return
			
		_player = result[1]
		
	Global.prize_api.request_prizes(0, 10)
	
func _on_prizes(ok :bool, datas :Array):
	if not ok:
		emit_signal("error")
		return
		
	loading.visible = false
	animation_player.play("show_prize")
	
	if not ok:
		return
		
	for i in datas:
		var item :PrizeApi.Prize = i
		var prize :PrizeItem = preload("res://assets/ui/prize_item/prize_item.tscn").instantiate()
		prize.id = item.id
		prize.prize_name = item.prize_name
		prize.prize_image_url = item.prize_image_url
		prize.prize_level = item.prize_level
		prize.background_color = Color.from_string(item.background_color, Color.BURLYWOOD)
		prize.can_redeem = false
		prize.redeem.connect(_on_prize_redeem)
		v_box_container.add_child(prize)
		
	_validate_can_redeem_prizes()
	
func _validate_can_redeem_prizes():
	if _player == null:
		return
		
	for i in v_box_container.get_children():
		var prize :PrizeItem = i
		Global.prize_api.request_check_redeem(_player.id, prize.id)
		var result :Array = await Global.prize_api.check_redeem
		if not result[0]:
			return
			
		var is_exist :bool = result[1]
		var require_level_ok :bool = (prize.prize_level < _player_rank_level)
		prize.set_can_redeem(not is_exist and require_level_ok)
	
func _on_prize_redeem(_prize_id :int, _prize_name :String):
	if _player == null:
		return
		
	redeem_prize_dialog.visible = true
	redeem_prize_dialog.player_id = _player.id
	redeem_prize_dialog.prize_id = _prize_id
	redeem_prize_dialog.prize_name = _prize_name
	redeem_prize_dialog.show_redeem_confirm()
	
func _remove_child(node :Control):
	for i in node.get_children():
		node.remove_child(i)
		i.queue_free()
		
	node.custom_minimum_size.y = 0
	
func _one_rank(ok :bool, data :RanksApi.Rank):
	if not ok:
		return
		
	_player_rank_level = data.rank_level
	
	player_prize_redeem.visible = true
	label_player_name.text = data.player_name
	label_player_level.text  = "%s %s" % [tr("LEVEL") ,data.rank_level]
	player_avatar.texture = await Global.get_avatar_image(self, data.player_id, data.player_avatar)
	
func _on_back_button_pressed():
	animation_player.play_backwards("show_prize")
	await animation_player.animation_finished
	emit_signal("back")
	
func _on_redeem_prize_redeem_completed(ok :bool):
	if not ok:
		return
		
	animation_player.play_backwards("show_prize")
	await animation_player.animation_finished
	emit_signal("back")













