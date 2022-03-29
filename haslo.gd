extends Control

var passwords = ["ulo2023", "ULOulo", "uloULO", "ULO23", "ulo23", "23ULO"]
var correct

var buffer = ""

func _ready():
	$input/Label.text = ""
	randomize()
	passwords.shuffle()
	correct = passwords.front()
	$pass/Label.text = correct
	for i in $przyciski.get_children():
		i.connect("pressed", self, "addToBuffer", [i.name])
		
func addToBuffer(x):
	buffer = buffer + x
	$input/Label.text = $input/Label.text + "*"
	if buffer == correct:
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)


func _on_nie_pressed():
	buffer = ""
	$input/Label.text = ""
