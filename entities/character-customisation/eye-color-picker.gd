extends Control

signal changeEyeColor(name)

func _ready():
	for i in $GridContainer.get_children():
		i.connect("pressed", self, "_on_eye_color_button_pressed", [i.name])

func _on_eye_color_button_pressed(name):
	emit_signal("changeEyeColor", name)
	