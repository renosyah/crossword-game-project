extends Control

@onready var animated_background :AnimatedBackground = $CanvasLayer/Control/animated_background
@onready var loading = $CanvasLayer/Control/loading

# menu
@onready var login = $CanvasLayer/Control/SafeArea/login

# Called when the node enters the scene tree for the first time.
func _ready():
	loading.visible = false
	
	OAuth2.sign_in_completed.connect(_sign_in_completed)
	Admob.initialization_finish.connect(_admob_initialization_finish)
	
	await get_tree().create_timer(1).timeout
	animated_background.set_stage(1)
	
	login.show_icon()
	
	await get_tree().create_timer(2).timeout
	animated_background.set_stage(2)
	login.show_login_form()
	
func _on_login_on_sign_in_press():
	OAuth2.sign_in()
	
func _sign_in_completed():
	login.visible = false
	loading.visible = true
	animated_background.set_stage(3, "_empty")
	Admob.initialize()
	
func _admob_initialization_finish():
	loading.visible = false
	animated_background.set_stage(3)
	# to main menu







