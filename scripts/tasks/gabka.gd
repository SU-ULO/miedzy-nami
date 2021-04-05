extends Sprite

var clickDelta = Vector2()
var pressed: bool = false

func _input(event):
	if event is InputEventMouseMotion:
		if pressed:
			position = get_viewport().get_mouse_position() - clickDelta
	if event is InputEventMouseButton || event is InputEventScreenTouch:
		if !event.is_pressed():
			pressed = false

func _on_gabka_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if event.is_pressed():
			pressed = true
			clickDelta = (get_viewport().get_mouse_position() - position)
