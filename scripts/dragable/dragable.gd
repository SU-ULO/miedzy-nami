extends Node2D

var clickDelta = Vector2()

onready var control = null
var own_area = null
var active = true

func _ready():
	own_area = get_child(0)
	own_area.connect("input_event", self, "inputEvent")

# input inside own_area
func inputEvent(_viewport, event, _shape):
	if control != null and active:
		if event is InputEventMouseMotion:
			if self == control.dragged:
				self.position = get_viewport().get_mouse_position() - clickDelta
		
		if event is InputEventMouseButton:
			if event.is_pressed():
				control.toDrag.append(self.get_index())
				if control.toDrag.max() == self.get_index():
					control.drag_on(self)
			else:
				if control.dragged == self:
					control.toDrag.clear()
					control.drag_off(self)

func _input(event):
	if control != null and active:
		if event is InputEventMouseMotion:
			if self == control.dragged:
				self.position = get_viewport().get_mouse_position() - clickDelta
		
		if event is InputEventMouseButton:
			if !event.is_pressed():
				if control.dragged == self:
					control.toDrag.clear()
					control.drag_off(self)
