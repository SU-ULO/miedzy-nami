extends Control

#icons are temporary

signal sabotage(name)

func _ready():
	for i in get_children():
		i.connect("pressed", self, "sabotage_start", [i.name])

func sabotage_start(name):
	pass
