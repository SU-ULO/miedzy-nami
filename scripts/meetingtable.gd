extends Node2D

var gui
var player

func _ready():
	add_to_group("interactable")
	add_to_group("entities")
	
func Interact(body):
	player = body
	gui = load("res://gui/meetingbutton.tscn").instance()
	gui.connect("emergency_meeting_requested", self, "call_meeting")
	gui.meetings_left = body.meetings_left
	gui.sabotage_on = bool(body.currentSabotage != 2 && body.currentSabotage != 0)
	player.get_node("GUI").add_to_canvas(gui)
	gui.start_gui()

func EndInteraction(body):
	if gui != null:
		body.get_node("GUI").clear_canvas()
		player = null
		gui = null

func call_meeting():
	player.meetings_left -= 1
	get_tree().get_root().get_node("Start").network.request_meeting(-1)
