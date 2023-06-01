extends MarginContainer

@export var hp :int
@export var max_hp :int

@onready var hp_template = $Control/hp_template
@onready var hp_empty_template = $Control/hp_empty_template

@onready var hp_row = $HBoxContainer/hp_row
@onready var hp_empty_row = $HBoxContainer/hp_empty_row

var tween :Tween

func display_hp():
	hp_row.show()
	hp_empty_row.show()
	
	for i in hp_row.get_children():
		hp_row.remove_child(i)
		i.queue_free()
		
	for i in hp_empty_row.get_children():
		hp_empty_row.remove_child(i)
		i.queue_free()
		
	for i in max_hp:
		if i < hp:
			var hp_image = hp_template.duplicate()
			hp_image.show()
			hp_row.add_child(hp_image)
			
		else:
			var hp_image = hp_empty_template.duplicate()
			hp_image.show()
			hp_empty_row.add_child(hp_image)
	
	
func pop_hp(count :int = 1):
	for i in count:
		if hp_row.get_children().is_empty():
			return
			
		if tween:
			tween.kill()
			
		tween = create_tween()
		var last :TextureRect = hp_row.get_children().back()
		
		last.scale = Vector2.ONE * 1.6
		tween.tween_property(last, "scale", Vector2.ZERO, 0.6).set_trans(Tween.TRANS_QUAD)
		await tween.finished
		
		hp_row.remove_child(last)
		last.queue_free()
		
		hp_row.visible = hp_row.get_child_count() > 0
		
		if tween:
			tween.kill()
			
		tween = create_tween()
		
		var hp_image = hp_empty_template.duplicate()
		hp_image.show()
		hp_empty_row.add_child(hp_image)
		hp_image.scale = Vector2.ZERO
		tween.tween_property(hp_image, "scale", Vector2.ONE * 1, 0.4).set_trans(Tween.TRANS_SINE)
	













