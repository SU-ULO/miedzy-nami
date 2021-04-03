extends Control

var count = 4

func _ready():
	pass

func im_good():
	count -=1
	if count == 0:
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
		
func im_bad():
	count+=1
