extends Area2D

#basic item draging functionality for Node2D

var mouseIn = false
var clickDelta = Vector2()
var pickedUp = false
var isOnDesk = false
var desk
var active = true
var areaCount = 0

func _ready():
	# warning-ignore:return_value_discarded
	connect("input_event", self, "inputEvent")
	# warning-ignore:return_value_discarded
	connect("area_entered", self, "onDesk")
	# warning-ignore:return_value_discarded
	connect("area_exited", self, "offDesk")

func _input(event):
	if event is InputEventMouseMotion:
		if pickedUp:
			get_parent().position = get_viewport().get_mouse_position() - clickDelta
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if !event.is_pressed():
			pickedUp = false
			get_parent().get_parent().toDrag.clear()
			if isOnDesk:
				isOnDesk = false
				desk.name = "nie"
				active = false
				get_parent().get_parent().DeskComplete()
				get_parent().frame = 1
				get_parent().scale = Vector2(0.5, 0.5)
				get_parent().position = desk.get_parent().position + Vector2(0, -160)
				get_parent().z_index = 1

func inputEvent(_viewport, event, _shape):
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if event.is_pressed():
					if active:
						get_parent().get_parent().toDrag.append(get_parent().get_index())
						if get_parent().get_parent().toDrag.min() == get_parent().get_index():
								pickedUp = true
								clickDelta = (get_viewport().get_mouse_position() - get_parent().position)

func onDesk(area):
	if area.name == "lawka":
		areaCount+=1
		isOnDesk = true
		desk = area

func offDesk(area):
	if area.name == "lawka":
		areaCount-=1
		if areaCount == 0:
			isOnDesk = false
