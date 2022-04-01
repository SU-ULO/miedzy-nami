extends Control

signal changeClothes(name)

func _ready():
	for i in $GridContainer.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "_on_clothes_button_pressed", [i.name])


func _on_clothes_button_pressed(name):
	emit_signal("changeClothes", name)

func get_random():
	var x = $GridContainer.get_children()
	x.shuffle()
	emit_signal("changeClothes", x[0].name)
