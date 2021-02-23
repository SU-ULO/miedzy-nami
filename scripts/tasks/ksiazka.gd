extends Area2D

var mouseIn = false
var clickDelta = Vector2()
var pickedUp = false
var inFront = false
var inBox = false
var main

func _ready():
	# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "isAbleToBePicked")
	# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "notAbleToBePicked")
	# warning-ignore:return_value_discarded
	connect("area_entered", self, "isInBox")
	# warning-ignore:return_value_discarded
	connect("area_exited", self, "notInBox")
	main = get_parent().get_parent()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_index() == BUTTON_LEFT:
				if mouseIn:
					if get_parent().get_parent().toDrag.max() == get_parent().get_index():
						pickedUp = true
						if inBox && !inFront:
							main.toSort+=1

						clickDelta = (get_viewport().get_mouse_position() - get_parent().position)
		else:
			if pickedUp:
				pickedUp = false
				if inBox && !inFront:

						main.toSort-=1
						main.checkForEnd()

	elif event is InputEventMouseMotion:
		if pickedUp:
			get_parent().position = get_viewport().get_mouse_position() - clickDelta

func isAbleToBePicked():
	mouseIn = true
	get_parent().get_parent().toDrag.append(get_parent().get_index())
	
func notAbleToBePicked():
	mouseIn = false
	get_parent().get_parent().toDrag.erase(get_parent().get_index())
	
func isInBox(area):
	if area.name == "szafka-bok":
		inFront = true
	if area.name == "polka-blue" && self.name == "blue":
		inBox = true

	if area.name == "polka-red" && self.name == "red":
		inBox = true

	if area.name == "polka-green" && self.name == "green":
		inBox = true

func notInBox(area):
	if area.name == "szafka-bok":
		inFront = false
	if area.name == "polka-blue" && self.name == "blue":
		inBox = false

	if area.name == "polka-red" && self.name == "red":
		inBox = false

	if area.name == "polka-green" && self.name == "green":
		inBox = false

