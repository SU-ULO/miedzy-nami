extends Control

#icons are temporary
var cooldown
var curr_time
var sabotage
signal exit()

var bars

func _ready():
	for i in $Control.get_children():
		i.connect("pressed", self, "sabotage_start", [i.name])
	bars = []
	for i in $Control.get_children():
		bars.push_back(i.get_child(0))
	
func _process(_delta):
	for i in bars:
		var x = $Timer.time_left * 100 / cooldown
		if x == 0 && sabotage !=0:
			x = 100
		elif sabotage == 0 && $Timer.is_stopped():
			x = 0
		i.value = x

func sabotage_start(name):
	var network = get_tree().get_root().get_node("Start").network
	
	if name == "electrical":
		network.request_sabotage(1)
	if name == "door":
		network.request_sabotage(2)

func _on_exit_pressed():
	emit_signal("exit")

func refresh_self():
	if curr_time > 0:
		$Timer.wait_time = curr_time
		if sabotage == 0:
			$Timer.start()

func updateMap(newsabotage):
	sabotage = newsabotage
	if newsabotage != 0:
		curr_time = 0
	else:
		curr_time = cooldown
	refresh_self()
		
