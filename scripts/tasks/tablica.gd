extends Node2D

var count

func _ready():
	count = $tablica_czysta.get_children().size()
	
func imDone():
	count -=1
	if count == 0:
		$Timer.start()
		yield($Timer, "timeout")
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(self)