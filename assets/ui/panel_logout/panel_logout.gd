extends Control

signal close
signal logout

var _is_get_player_avatar :bool = false
@onready var avatar = $PanelLogout/VBoxContainer/HBoxContainer2/MarginContainer3/avatar
@onready var player_name_logout = $PanelLogout/VBoxContainer/HBoxContainer2/VBoxContainer/player_name_logout
@onready var player_email_logout = $PanelLogout/VBoxContainer/HBoxContainer2/VBoxContainer/player_email_logout
@onready var animation_player = $AnimationPlayer
@onready var color_rect = $ColorRect

func _ready():
	color_rect.mouse_filter = MOUSE_FILTER_IGNORE

func show_panel_logout():
	color_rect.mouse_filter = MOUSE_FILTER_STOP
	animation_player.play("show_panel_logout")
	player_name_logout.text = Global.player.player_name
	player_email_logout.text = Global.player.player_email
	_get_player_avatar()
	
func _get_player_avatar():
	if _is_get_player_avatar:
		return
		
	_is_get_player_avatar = true
	avatar.texture = await Global.get_avatar_image(self, Global.player.player_id, Global.player.player_avatar)
	_is_get_player_avatar = false

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		animation_player.play_backwards("show_panel_logout")
		color_rect.mouse_filter = MOUSE_FILTER_IGNORE
		emit_signal("close")
		
func _on_logout_pressed():
	animation_player.play_backwards("show_panel_logout")
	color_rect.mouse_filter = MOUSE_FILTER_IGNORE
	emit_signal("logout")
