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
	own_area.connect("area_entered", self, "isInBox")
	# warning-ignore:return_value_discarded
	own_area.connect("area_exited", self, "notInBox")

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
	if !main.books.has(body.name):
		main.books.append(body.name)
	clickDelta = (get_viewport().get_mouse_position() - body.position)

func drag_off():
	if main.dragged.inBox && !main.dragged.inFront:
		if main.books.has(main.dragged.name):
			main.books.erase(main.dragged.name)
	main.dragged = null

func isInBox(area):
	if area.name == "shelf-front":
		inFront = true
	
	if area.name == "shelf-blue" && own_area.name == "blue":
		inBox = true
	
	if area.name == "shelf-red" && own_area.name == "red":
		inBox = true
	
	if area.name == "shelf-green" && own_area.name == "green":
		inBox = true

func notInBox(area):
	if area.name == "shelf-front":
		inFront = false
	
	if area.name == "shelf-blue" && own_area.name == "blue":
		inBox = false
	
	if area.name == "shelf-red" && own_area.name == "red":
		inBox = false
	
	if area.name == "shelf-green" && own_area.name == "green":
		inBox = false
