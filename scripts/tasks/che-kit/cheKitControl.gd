extends "res://scripts/dragable/dragableControl.gd"

var names = {
	"CaOH": "Ca(OH)2", 
	"HCl": "HCl", 
	"NaOH": "NaOH", 
	"probowka": "probówka", 
	"slomka": "słomka", 
	"zlewka": "zlewka", 
	"HNO": "HNO3", 
	"szkielko": "szkiełko",
	"papierki": "papierki",
	"szmatka": "szmatka"
}

var kits = [
	["NaOH","probowka", "slomka", "zlewka", "CaOH", "HCl"],
	["szkielko", "szmatka", "HCl", "HNO"],
	["HNO", "NaOH", "papierki", "probowka", "CaOH", "HCl"]
]

var taskKit
var userKit = []
var labels

func _ready():
	for node_path in connected:
		# warning-ignore:return_value_discarded
		get_node(node_path).get_child(0).connect("area_entered", self, "state_changed", [get_node(node_path), true])
		# warning-ignore:return_value_discarded
		get_node(node_path).get_child(0).connect("area_exited", self, "state_changed", [get_node(node_path), false])
	
	# randomize a kit for task
	randomize()
	taskKit = kits[randi() % kits.size()]
	taskKit.sort()
	print(taskKit)

	# set labels on sticky note
	labels = get_node("Sticky/List").get_children()
	var iter = 0
	for item in taskKit:
		labels[iter].text = "1x " + str(names[item])
		labels[iter].name = item
		iter += 1

func is_valid(item):
	if item.inBox and !item.inFront:
		return true
	return false

func set_valid(item, state):
	.set_valid(item, state)
	if !labels: return
	
	for label in labels:
		if label.name == item.name:
			if state:
				label.text = "0x " + str(names[item.name])
				label.set("custom_colors/font_color", Color(0.19,0.19,0.19,0.5)) # dim gray
			else:
				label.text = "1x " + str(names[item.name])
				label.set("custom_colors/font_color", Color(0.19,0.19,0.19,1)) # normal gray
		if state:
			if !userKit.has(item.name):
				userKit.append(item.name)
		else:
			if userKit.has(item.name):
				userKit.erase(item.name)
	check_correct()

func check_correct():
	userKit.sort()
	if taskKit == userKit:
		print("ok")
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)

func state_changed(area, item, state):
	if area.name == "koszyk-bottom":
		item.inFront = state
		item.z_index = int(state)
	if  area.name == "koszyk":
		item.inBox = state
