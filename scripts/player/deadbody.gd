extends Node2D

var color
var lateOwner
var killer

func _ready():
	add_to_group("deadbody")
	add_to_group("interactable")
	add_to_group("entities")

func Interact(_body):
	get_tree().get_root().get_node('Start').network.request_meeting(-1) #dead person id should be here

func EndInteraction(_body):
	pass
