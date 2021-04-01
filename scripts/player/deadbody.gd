extends Node2D

var color
var lateOwner
var killer

func _ready():
	add_to_group("deadbody")
	add_to_group("interactable")
	add_to_group("entities")

func Interact(_body):
	Globals.start.network.request_meeting(lateOwner) #dead person id should be here

func EndInteraction(_body):
	pass
