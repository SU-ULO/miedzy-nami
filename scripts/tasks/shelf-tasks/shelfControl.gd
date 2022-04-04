extends "res://scripts/dragable/dragableControl.gd"

func _ready():
	var shelf = get_node("shelf")
	for child in shelf.get_children():
		# warning-ignore:return_value_discarded
		child.connect("area_entered", self, "state_changed", [child.name, true])
		# warning-ignore:return_value_discarded
		child.connect("area_exited", self, "state_changed", [child.name, false])

func is_valid(item):
	if item.inBox and !item.inFront:
		return true
	return false

func set_valid(item, state):
	.set_valid(item, state)
	after_validation()

func after_validation():
	if totalValid == connected.size():
		print("ok")
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)

func state_changed(area, _name, state):
	var item = area.get_parent()
	if _name == "shelf-front":
		item.inFront = state
	if "shelf-" + area.name == _name:
		item.inBox = state
