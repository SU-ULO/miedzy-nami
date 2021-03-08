extends Control

signal changeClothes(name)

func _ready():
	for i in $GridContainer.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "_on_clothes_button_pressed", [i.name])


func _on_clothes_button_pressed(name):
	emit_signal("changeClothes", name)
