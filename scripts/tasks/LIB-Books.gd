extends Node2D

var toDrag = []
var toSort = 9

var dragged = null

func checkForEnd():
	if toSort == 0:
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
