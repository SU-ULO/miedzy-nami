extends StaticBody2D

var gui
var bodyxx

func _ready():
	add_to_group("entities")

func check_on(type):
	if type == 3:
		add_to_group("interactable")

func check_off(type):
	if type == 3:
		if is_in_group("interactable"):
			remove_from_group("interactable")
		if gui.is_inside_tree():
			$Timer.start()
			yield($Timer, "timeout")
			gui.queue_free()
			if bodyxx != null:
				bodyxx.ui_canceled()
func Interact(body):
	bodyxx = body
	gui = load("res://gui/comms.tscn").instance()
	get_owner().get_node("CanvasLayer").add_child(gui)
	print(gui)
func EndInteraction(_body):
	if gui!=null:
		gui.queue_free()
		bodyxx = null