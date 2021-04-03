extends Node2D

var deskCount = 4

var toDrag = []

func DeskComplete():
	deskCount-=1
	if deskCount == 0:
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
