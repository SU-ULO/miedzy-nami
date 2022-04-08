extends Control

export var part_name = ""

signal changePart(part, name)

func _ready():
	for i in $GridContainer.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "_on_button_pressed", [i.name])

func _on_button_pressed(name):
	emit_signal("changePart", part_name, name)
	
func get_random():
	var x = $GridContainer.get_children()
	x.shuffle()
	emit_signal("changePart", part_name, x[0].name)
