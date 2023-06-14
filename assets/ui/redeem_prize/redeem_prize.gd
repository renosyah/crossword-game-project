extends Control

signal redeem_completed(ok)

@export var player_id :int
@export var prize_id :int
@export var prize_name :String

@onready var _confirm_redeem_title = $confirm_redeem_dialog/VBoxContainer/title
@onready var _confirm_redeem_description = $confirm_redeem_dialog/VBoxContainer/HBoxContainer2/description
@onready var _confirm_redeem_yes_button_title = $confirm_redeem_dialog/VBoxContainer/HBoxContainer/redeem_button/CenterContainer/HBoxContainer/button_title
@onready var _confirm_redeem_no_button_title = $confirm_redeem_dialog/VBoxContainer/HBoxContainer3/no_button/CenterContainer/no

@onready var _success_redeem_title = $success_redeem_dialog/VBoxContainer/title
@onready var _success_redeem_description = $success_redeem_dialog/VBoxContainer/HBoxContainer2/description
@onready var _success_redeem_button_title = $success_redeem_dialog/VBoxContainer/HBoxContainer/ok_button/CenterContainer/HBoxContainer/button_title

@onready var _animation_player = $AnimationPlayer

func _ready():
	_confirm_redeem_title.text = tr("REDEEM_PRIZE")
	_confirm_redeem_yes_button_title = tr("REDEEM")
	_confirm_redeem_no_button_title.text = tr("THANKS_LATER")
	
	_success_redeem_title.text = tr("REDEEM_PRIZE")
	_success_redeem_button_title.text = tr("CLOSE")
	
func show_redeem_confirm():
	_animation_player.play("RESET")
	
	_confirm_redeem_description.text = "%s %s?" % [tr("WANT_REDEEM_PRIZE"), prize_name]
	_success_redeem_description.text = tr("REDEEM_PRIZE_SUCCESS") % prize_name
	
	_animation_player.play("show_redeem_confirm")
	
func _on_redeem_button_pressed():
	_animation_player.play("redeeming")
	await _animation_player.animation_finished
	
	Global.prize_api.redeem_prizes(player_id, prize_id)
	var ok :bool = await Global.prize_api.redeemed
	if not ok:
		_animation_player.play("RESET")
		emit_signal("redeem_completed", false)
		return
		
	_animation_player.play("show_redeem_success")
	await _animation_player.animation_finished
	
func _on_no_button_pressed():
	_animation_player.play_backwards("show_redeem_confirm")
	await _animation_player.animation_finished
	visible = false
	
func _on_ok_button_pressed():
	_animation_player.play_backwards("show_redeem_success")
	await _animation_player.animation_finished
	emit_signal("redeem_completed", true)
	visible = false
