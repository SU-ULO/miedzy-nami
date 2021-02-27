extends Node2D

export var linkedcameras = []

func _ready():
	self.add_to_group("entities")
	self.add_to_group("interactable")
	self.add_to_group("cameras")
	
func open(body):
	get_node(linkedcameras[0]).get_node("Camera2D").make_current()
	
func close(body):
	body.get_node("Camera").make_current()
