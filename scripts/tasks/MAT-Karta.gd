extends Node2D

var deskCount = 4

func DeskComplete():
	deskCount-=1
	if deskCount == 0:
		$Timer.start()
		yield($Timer, "timeout")
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(self)
