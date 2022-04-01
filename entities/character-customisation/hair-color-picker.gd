extends Control

signal changeHairColor(name)

func _ready():
	for i in $GridContainer.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "_on_hair_color_button_pressed", [i.name])

func _on_hair_color_button_pressed(name):
	emit_signal("changeHairColor", name)
	
func get_random():
	var x = $GridContainer.get_children()
	x.shuffle()
	emit_signal("changeHairColor", x[0].name)
