extends Control

var bugcount = 6

func _ready():
	pass # Replace with function body.

func bugKilledRIP():
	bugcount-=1
	if bugcount == 0:
		$Timer2.start()
		yield($Timer2, "timeout")
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(self)