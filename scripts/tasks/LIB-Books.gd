extends Node2D

var toDrag = []
var toSort = 9
func _ready():
	pass # Replace with function body.

func checkForEnd():
	if toSort == 0:
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGui.TaskWithGuiCompleteTask(self)
