extends Area2D

var mouseIn = false
var clickDelta = Vector2()
var pickedUp = false
var inFront = false
var inBox = false
var main

func _ready():
	# warning-ignore:return_value_discarded
	connect("area_entered", self, "isInBox")
	# warning-ignore:return_value_discarded
	connect("area_exited", self, "notInBox")
	# warning-ignore:return_value_discarded
	connect("input_event", self, "inputEvent")
	get_parent().z_index = -1
	main = get_owner()

func _input(event):
	if event is InputEventMouseMotion:
		if pickedUp:
			get_parent().position = get_viewport().get_mouse_position() - clickDelta
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if !event.is_pressed():
			main.toDrag.clear()
			pickedUp = false
			if inBox && !inFront:
					if !main.userKit.has(get_parent().name):
						main.userKit.append(get_parent().name)
						main.checkForEnd()
			else:
				if main.userKit.has(get_parent().name):
					main.userKit.erase(get_parent().name)
					main.checkForEnd()

func inputEvent(_viewport, event, _shape):
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if event.is_pressed():
			main.toDrag.append(get_parent().get_index())
			if main.toDrag.min() == get_parent().get_index():
				pickedUp = true
				clickDelta = (get_viewport().get_mouse_position() - get_parent().position)

func isInBox(area):
	if area.name == "koszyk-bottom":
		inFront = true
		get_parent().z_index = 1
	if area.name == "koszyk":
		inBox = true

func notInBox(area):
	if area.name == "koszyk-bottom":
		inFront = false
		get_parent().z_index = -1
	if area.name == "koszyk":
		inBox = false
