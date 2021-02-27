extends Sprite

var pressed
var mouseIn
var clickDelta

func _ready():
	pass 
	

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_index() == BUTTON_LEFT:
				if mouseIn:
					pressed = true
					clickDelta = (get_viewport().get_mouse_position() - position)
		else:
			pressed = false
	elif event is InputEventMouseMotion:
		if pressed:
			position = get_viewport().get_mouse_position() - clickDelta


func _on_gabka_mouse_entered():
	mouseIn = true


func _on_gabka_mouse_exited():
	mouseIn = false
