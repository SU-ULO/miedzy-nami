extends Control

signal changeAcc(name)

func _ready():
	for i in $GridContainer.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "_on_acc_button_pressed", [i.name])

func _on_acc_button_pressed(name):
	emit_signal("changeAcc", name)

func get_random():
	var x = $GridContainer.get_children()
	x.shuffle()
	emit_signal("changeAcc", x[0].name)