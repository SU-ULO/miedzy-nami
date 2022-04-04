extends Node2D

var toDrag = []
var dragged = null

export var connected = []
var connectedStates = []
var totalValid = 0
 
# resize connectedStates to connected.size with value representing
# current state of item (valid position or invalid)
# set control on all connected to self
func _ready():
	for iter in range(connected.size()):
		var item = self.get_node(connected[iter])
		var state = is_valid(item)
		item.control = self
		connectedStates.append(state)
		set_valid(item, state)

# override this to set custom conditions for valid item position
func is_valid(_item):
	return true

# setter
func set_valid(item, state: bool):
	var index = -1
	
	for iter in range(connected.size()):
		if get_node(connected[iter]) == item:
			index = iter
			break
	
	if index != -1:
		if connectedStates[index] != state:
			if state: totalValid += 1
			else: totalValid -= 1
			connectedStates[index] = state

func drag_on(body):
	if dragged != null:
		drag_off(dragged)
	dragged = body
	set_valid(body, false)
	body.clickDelta = (get_viewport().get_mouse_position() - body.position)

func drag_off(body):
	if dragged == body: 
		if is_valid(body):
			set_valid(body, true)
		dragged = null
