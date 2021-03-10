extends Node2D


func _ready():
	add_to_group("deadbody")
	add_to_group("interactable")
	add_to_group("entities")

func Interact(body):
	pass

func EndInteraction(body):
	pass
