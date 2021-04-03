extends Node2D

var sabotageOn = true
var gui
var player

func _ready():
	add_to_group("entities")
	add_to_group("sabotage")

func Interact(body):
	player = body
	gui = load("res://gui/electrical.tscn").instance()
	gui.switches = body.electrical_switches
	gui.good = body.electrical_good
	body.get_node("GUI").add_to_canvas(gui)

func EndInteraction(body):
	body.get_node("GUI").clear_canvas()
	player = null

func check_on(type):
	if type == 1:
		add_to_group("interactable")

func check_off(type):
	if type == 1:
		# will be fixed later
		if self.is_in_group("interactable"):
			self.remove_from_group("interactable")
		
		$Timer.start()
		yield($Timer, "timeout")
		if player != null:
			player.ui_canceled()
