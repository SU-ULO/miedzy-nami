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
	connect("mouse_entered", self, "isAbleToBePicked")
	# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "notAbleToBePicked")
	# warning-ignore:return_value_discarded
	connect("area_entered", self, "onDesk")
	# warning-ignore:return_value_discarded
	connect("area_exited", self, "offDesk")
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_index() == BUTTON_LEFT:
				if mouseIn:
					if get_parent().get_parent().toDrag.max() == get_parent().get_index():
						if active:
							pickedUp = true
							clickDelta = (get_viewport().get_mouse_position() - get_parent().position)
		else:
			pickedUp = false
			if isOnDesk:
				isOnDesk = false
				desk.name = "nie"
				active = false
				get_parent().get_parent().DeskComplete()
				get_parent().frame = 1
				get_parent().scale = Vector2(0.5, 0.5)
				get_parent().position = desk.get_parent().position + Vector2(0, -160)
				get_parent().z_index = 1
	elif event is InputEventMouseMotion:
		if pickedUp:
			get_parent().position = get_viewport().get_mouse_position() - clickDelta
		
		
			

func isAbleToBePicked():
	if active:
		mouseIn = true
		get_parent().get_parent().toDrag.append(get_parent().get_index())

func notAbleToBePicked():
	mouseIn = false
	get_parent().get_parent().toDrag.erase(get_parent().get_index())

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
