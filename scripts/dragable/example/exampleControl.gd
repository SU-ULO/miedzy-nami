extends "res://scripts/dragable/dragableControl.gd"

var inside = []

func _ready():
	# warning-ignore:return_value_discarded
	get_node("Area2D").connect("area_entered", self, "state_changed", [true])
	# warning-ignore:return_value_discarded
	get_node("Area2D").connect("area_exited", self, "state_changed", [false])

func is_valid(item):
	if inside.has(item): return true
	else: return false

func set_valid(item, state):
	.set_valid(item, state)
	check_correct()

func check_correct():
	get_node("valid-label").text = "poprawne: " + str(totalValid)
	if (totalValid == connected.size()): 
		print("ok")

func state_changed(area, state):
	var item = area.get_parent()
	if state:
		if !inside.has(item):
			inside.append(item)
	else:
		if inside.has(item):
			inside.erase(item)
