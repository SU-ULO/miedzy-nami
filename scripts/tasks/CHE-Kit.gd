extends Node2D

var inbox = Dictionary()

var toDrag = []

var trueNames = {"CaOH": "Ca(OH)2", "HCl": "HCl", "NaOH": "NaOH", "probowka": "probówka", "slomka": "słomka", "zlewka": "zlewka", "HNO": "HNO3", "szkielko": "szkiełko"}

var kits = [["CaOH", "HCl", "NaOH","probowka", "slomka", "zlewka"],["HCl", "HNO", "szkielko", "szmatka"],["CaOH", "HCl", "HNO", "NaOH", "papierki", "probowka"]] #has to be sorted
var kitsCount
var taskKit
var userKit = []
var labels

func getAllNodes(node):
	var list = []
	for item in node.get_children():
		list.append(item)
	return list

func _ready():
	randomize()
	kitsCount = kits.size()
	taskKit = kits[randi()%kitsCount]
	print(taskKit)
	
	labels = getAllNodes($Sprite/VBoxContainer)
	var iter = 0
	
	for item in taskKit:
		if item in trueNames:	
			labels[iter].text = "1x " + str(trueNames[item])
		else:
			labels[iter].text = "1x " + str(item)
		iter += 1

func checkForEnd():
	userKit.sort()
	var iter = 0;
	
	for item in taskKit:
		if userKit.has(item):
			print("item in")
			if item in trueNames:	
				labels[iter].text = "0x " + str(trueNames[item])
			else:
				labels[iter].text = "0x " + str(item)
			labels[iter].set("custom_colors/font_color", Color(0.19,0.19,0.19,0.5)) #dim gray
		else:
			if item in trueNames:	
				labels[iter].text = "1x " + str(trueNames[item])
			else:
				labels[iter].text = "1x " + str(item)
			labels[iter].set("custom_colors/font_color", Color(0.19,0.19,0.19,1)) #dim gray
		iter += 1
	
	if userKit == taskKit:
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
