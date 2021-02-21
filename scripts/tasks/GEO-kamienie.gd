extends Node2D

var toDrag = []
var toSort = 6
func _ready():
	pass # Replace with function body.

func checkForEnd():
	if toSort == 0:
		$Timer.start()
		yield($Timer, "timeout")
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(self)
