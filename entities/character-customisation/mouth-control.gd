extends Control

signal changeMouth(name)

func _ready():
	for i in $GridContainer.get_children():
		i.connect("pressed", self, "_on_nose_button_pressed", [i.name])


func _on_nose_button_pressed(name):
	emit_signal("changeMouth", name)