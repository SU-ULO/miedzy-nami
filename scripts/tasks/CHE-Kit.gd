extends Node2D

var inbox = Dictionary()

var kits = [["CaOH2", "HCl", "NaOH", "slomka"],["HCl", "HNO", "szkielko", "szmatka"],["CaOH", "HCl", "HNO", "NaOH", "papierki"]] #has to be sorted
var kitsCount
var taskKit
var userKit = []

func _ready():
	randomize()
	kitsCount = kits.size()
	taskKit = kits[randi()%kitsCount]
	print(taskKit)

func checkForEnd():
	userKit.sort()
	if userKit == taskKit:
		print("jej")
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(self)
