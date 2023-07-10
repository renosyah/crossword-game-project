extends Button

@onready var texture_progress_bar = $TextureProgressBar
@onready var texture_rect = $TextureRect

func set_enable(enable :bool):
	disabled = not enable
	texture_rect.modulate.a = 0.5 if disabled else 1.0

func update_progress(value, max_value :int):
	texture_progress_bar.value = value
	texture_progress_bar.max_value = max_value
