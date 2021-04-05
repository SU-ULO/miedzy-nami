extends Sprite

var clickDelta = Vector2()

var inFront = false
var inBox = false

var main = null
var own_area = null

func _ready():
	main = get_owner()
	own_area = get_child(0)
	
	# warning-ignore:return_value_discarded
	own_area.connect("input_event", self, "inputEvent")
	# warning-ignore:return_value_discarded
	own_area.connect("area_entered", self, "stateChanged", [true])
	# warning-ignore:return_value_discarded
	own_area.connect("area_exited", self, "stateChanged", [false])

func _input(event):
	if event is InputEventMouseMotion:
		if self == main.dragged:
			self.position = get_viewport().get_mouse_position() - clickDelta
	if event is InputEventMouseButton:
		if !event.is_pressed():
			if main.dragged != null:
				main.toDrag.clear()
				drag_off()
				main.checkForEnd()

func inputEvent(_viewport, event, _shape):
	if event is InputEventScreenTouch || event is InputEventMouseButton:
		if event.is_pressed():
			main.toDrag.append(self.get_index())
			if main.toDrag.max() == self.get_index():
				drag_on(self)

func drag_on(body):
	if main.dragged != null:
		drag_off()
	main.dragged = body
	if !main.wrong.has(body.name):
		main.wrong.append(body.name)
		print("+1 ", main.wrong.size())
	clickDelta = (get_viewport().get_mouse_position() - body.position)

func drag_off():
	if main.dragged.inBox && !main.dragged.inFront:
		if main.wrong.has(main.dragged.name):
			main.wrong.erase(main.dragged.name)
			print("-1 ", main.wrong.size())
	main.dragged = null

func stateChanged(area, state):
	if area.name == "shelf-front":
		inFront = state
	
	for color in main.colors:
		if area.name == "shelf-" + color and own_area.name == color:
			inBox = state
