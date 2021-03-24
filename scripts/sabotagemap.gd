extends Control

#icons are temporary

signal sabotage(name)
signal exit()

func _ready():
	for i in get_children():
		i.connect("pressed", self, "sabotage_start", [i.name])

func sabotage_start(name):
	var network = get_tree().get_root().get_node("Start").network
	
	if name == "electrical":
		network.request_sabotage(1)
	if name == "door":
		network.request_sabotage(2)
	if name == "comms":
		network.request_sabotage(3)

func _on_exit_pressed():
	emit_signal("exit")
