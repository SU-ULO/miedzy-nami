extends Node2D


func _ready():
	add_to_group("deadbody")
	add_to_group("interactable")
	add_to_group("entities")

func Interact(_body):
	print("heh")

func EndInteraction(_body):
	pass
