extends Control

var Task

func _ready():
	Task = load("res://scripts/tasks/Task.cs")
	print(Task)
	
func updateGUI():
	var content = ""
	for i in get_parent().localTaskList:
		content += Task.ToString()
		content += str(i)
		content += "\n"
	$tasklist.text = content

