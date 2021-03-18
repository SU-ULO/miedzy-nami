extends Control

var switches = [1, 1, 0, 1, 0] # 1 is down
var good = [0, 0, 1, 1, 0] #state in with switches have to be, 1 us down
func _ready():
	for i in range(1, 6):
		# warning-ignore:return_value_discarded
		get_node("GridContainer/switch" + str(i)).connect("pressed", self, "toggle", [i])
	loadStatus()
func remoteToggle(number):
	switches[number-1]=int(!switches[number-1])
	toggleLight(number)
	get_node("GridContainer/switch" + str(number)).pressed = !get_node("GridContainer/switch" + str(number)).pressed

func toggleLight(number):
	get_node("GridContainer/switch" + str(number) + "/status").pressed = !get_node("GridContainer/switch" + str(number) + "/status").pressed

func randomizeSwitches():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	good.clear()
	for _i in range(0, 5):
		good.append(rng.randi_range(0, 1))

func loadStatus():
	for i in range(1, 6):
		get_node("GridContainer/switch" + str(i)).pressed = switches[i-1]
		get_node("GridContainer/switch" + str(i) + "/status").pressed = !(switches[i-1] && good[i-1])
func toggle(number):
	switches[number-1]=int(!switches[number-1])
	toggleLight(number)
	checkWin()

func checkWin():
	if switches == good:
		print("yay u won, end sabotage")
