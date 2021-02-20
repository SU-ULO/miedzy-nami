extends StaticBody2D

export var link = [] # array of nodepaths the vent is supposed to link to
onready var pos = self.position

func teleport(body):
	if link.empty():
		body.position = pos
	else:
		body.position = get_node(link[0]).position

func _ready():
	self.add_to_group("entities")
	self.add_to_group("interactable")
	self.add_to_group("vents")
	pass
