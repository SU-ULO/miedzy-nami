extends Control

signal changeHair(name)

func _ready():
	for i in $GridContainer.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "_on_hair_button_pressed", [i.name])

func _on_hair_button_pressed(name):
	emit_signal("changeHair", name)
	
func get_random():
	var x = $GridContainer.get_children()
	x.shuffle()
	emit_signal("changeHair", x[0].name)
