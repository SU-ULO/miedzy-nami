extends "res://scripts/dragable/dragableControl.gd"

func _ready():
	var karty = get_node("karty")
	for child in karty.get_children():
		# warning-ignore:return_value_discarded
		child.get_child(0).connect("area_entered", self, "state_changed", [child, true])
		# warning-ignore:return_value_discarded
		child.get_child(0).connect("area_exited", self, "state_changed", [child, false])

func is_valid(item):
	if item.inBox > 0:
		return true
	return false

func set_valid(item, state):
	.set_valid(item, state)
	
	if state:
		item.active = false
		item.currentDesk.get_child(0).name = "set"
		item.frame = 1
		item.scale = Vector2(0.5, 0.5)
		item.position = item.currentDesk.position + Vector2(0, -160)
		item.z_index = 1
	
	check_correct()

func check_correct():
	if totalValid == connected.size():
		print("ok")
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
	
func state_changed(area, item, state):
	if area.name == "lawka":
		if state:
			item.inBox += 1
			item.currentDesk = area.get_parent()
		else:
			item.inBox -= 1
			if item.inBox < 1:
				item.currentDesk = null
