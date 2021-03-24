extends Control

var switches = [1, 1, 0, 1, 0] # 1 is down
var good = [0, 0, 1, 1, 0] #state in with switches have to be, 1 us down

func _ready():
	get_tree().get_root().get_node("Start").network.connect("gui_sync", self, "gui_sync")
	for i in range(1, 6):
		# warning-ignore:return_value_discarded
		get_node("GridContainer/switch" + str(i)).connect("pressed", self, "toggle", [i])
	loadStatus()
	
func gui_sync(gui_name: String, gui_data: Dictionary):
	if gui_name == self.name:
		switches = gui_data["switches"]
		good = gui_data["good"]
		loadStatus()	

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
		get_node("GridContainer/switch" + str(i) + "/status").pressed = !(switches[i-1] == good[i-1])
		
func toggle(number):
	switches[number-1]=int(!switches[number-1])
	toggleLight(number)
	checkWin()

func checkWin():
	get_tree().get_root().get_node("Start").network.request_gui_sync(self.name, {"switches":switches, "good":good})
	if switches == good:
		var network = get_tree().get_root().get_node("Start").network
		network.request_end_sabotage(1)
