extends Node2D

var gui
var bodyxx

func _ready():
	add_to_group("interactable")
	add_to_group("entities")
	
func Interact(body):
	bodyxx = body
	gui = load("res://gui/meetingbutton.tscn").instance()
	gui.connect("emergency_meeting_requested", self, "call_meeting")
	gui.meetings_left = body.meetings_left
	gui.sabotage_on = bool(body.currentSabotage != 2 && body.currentSabotage != 0)
	get_owner().get_node("CanvasLayer").add_child(gui)
	gui.start_gui()

func EndInteraction(_body):
	if gui!=null:
		gui.queue_free()

func call_meeting():
	bodyxx.meetings_left -= 1
	get_tree().get_root().get_node("Start").network.request_meeting(-1)
