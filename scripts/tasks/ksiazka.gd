extends Area2D

var clickDelta = Vector2()
var pickedUp = false
var inFront = false
var inBox = false
var main

func _ready():
	# warning-ignore:return_value_discarded
	connect("input_event", self, "inputEvent")
	# warning-ignore:return_value_discarded
	connect("area_entered", self, "isInBox")
	# warning-ignore:return_value_discarded
	connect("area_exited", self, "notInBox")
	main = get_parent().get_parent()

func _input(event):
	if event is InputEventMouseMotion:
		if pickedUp:
			get_parent().position = get_viewport().get_mouse_position() - clickDelta


func inputEvent(_viewport, event, _shape):
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if event.is_pressed():
					get_parent().get_parent().toDrag.append(get_parent().get_index())
					if get_parent().get_parent().toDrag.min() == get_parent().get_index():
						pickedUp = true
						if inBox && !inFront:
							main.toSort+=1
						clickDelta = (get_viewport().get_mouse_position() - get_parent().position)
		else:
			if pickedUp:
				get_parent().get_parent().toDrag.clear()
				pickedUp = false
				if inBox && !inFront:
					main.toSort-=1
					main.checkForEnd()
						
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

