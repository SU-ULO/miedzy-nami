extends Node2D

var toDrag = []
var wrong = []
export var colors = []

var dragged = null

func _ready():
	for child in get_node("items").get_children():
		wrong.append(child.name)

func checkForEnd():
	if wrong.empty():
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
