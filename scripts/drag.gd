extends Area2D

#basic item draging functionality for Node2D

var mouseIn = false
var clickDelta = Vector2()
var pickedUp = false

func _ready():
	connect("mouse_entered", self, "isAbleToBePicked")
	connect("mouse_exited", self, "notAbleToBePicked")

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_index() == BUTTON_LEFT:
				if mouseIn:
					pickedUp = true
					clickDelta = (get_viewport().get_mouse_position() - get_parent().position)
		else:
			pickedUp = false
	elif event is InputEventMouseMotion:
		if pickedUp:
			get_parent().position = get_viewport().get_mouse_position() - clickDelta
		
		
			

func isAbleToBePicked():
	mouseIn = true

func notAbleToBePicked():
	mouseIn = false

