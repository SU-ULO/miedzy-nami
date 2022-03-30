extends StaticBody2D

var gui
var bodyxx

func _ready():
	add_to_group("entities")
	add_to_group("sabotage")

func check_on(type):
	if type == 3:
		add_to_group("interactable")

func check_off(type):
	if type == 3:
		if is_in_group("interactable"):
			remove_from_group("interactable")
		if gui:
			if bodyxx:
				bodyxx.ui_canceled()

func Interact(body):
	bodyxx = body
	gui = load("res://gui/comms.tscn").instance()
	body.get_node("GUI").add_to_canvas(gui)
	print(gui)

func EndInteraction(body):
	if gui!=null:
		body.get_node("GUI").clear_canvas()
		bodyxx = null
