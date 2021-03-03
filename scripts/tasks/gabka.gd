extends Sprite

var pressed
var mouseIn
var clickDelta

func _ready():
	pass 
	

func _input(event):
	if event is InputEventMouseMotion:
		if pressed:
			position = get_viewport().get_mouse_position() - clickDelta


func _on_gabka_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if event.is_pressed():
			pressed = true
			clickDelta = (get_viewport().get_mouse_position() - position)
		else:
			pressed = false
