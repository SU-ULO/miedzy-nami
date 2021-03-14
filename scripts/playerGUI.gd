extends Control

var Task

func _ready():
	Task = load("res://scripts/tasks/Task.cs")
	
func updateGUI():
	var content = ""
	for i in get_owner().localTaskList:
		content += Task.ToString()
		content += str(i)
		content += "\n"
	$VBoxContainer/tasklist.text = content

