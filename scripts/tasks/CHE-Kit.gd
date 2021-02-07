extends Node2D

var inbox = Dictionary()

var kits = [["CaOH", "HCl", "NaOH", "slomka", "zlewka", "probowka"],["HCl", "HNO", "szkielko", "szmatka"],["CaOH", "HCl", "HNO", "NaOH", "papierki", "probowka"]] #has to be sorted
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
