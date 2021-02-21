extends Control

signal changeSkin(number)

func _ready():
	# warning-ignore:return_value_discarded
	$skin1.connect("pressed", self, "_on_skin_button_pressed", ["1"])
	# warning-ignore:return_value_discarded
	$skin2.connect("pressed", self, "_on_skin_button_pressed", ["2"])
	# warning-ignore:return_value_discarded
	$skin3.connect("pressed", self, "_on_skin_button_pressed", ["3"])
	# warning-ignore:return_value_discarded
	$skin4.connect("pressed", self, "_on_skin_button_pressed", ["4"])
	# warning-ignore:return_value_discarded
	$skin5.connect("pressed", self, "_on_skin_button_pressed", ["5"])
	# warning-ignore:return_value_discarded
	$skin6.connect("pressed", self, "_on_skin_button_pressed", ["6"])
	# warning-ignore:return_value_discarded
	$skin7.connect("pressed", self, "_on_skin_button_pressed", ["7"])
	# warning-ignore:return_value_discarded
	$skin8.connect("pressed", self, "_on_skin_button_pressed", ["8"])
	# warning-ignore:return_value_discarded
	$skin9.connect("pressed", self, "_on_skin_button_pressed", ["9"])
	# warning-ignore:return_value_discarded
	$skin10.connect("pressed", self, "_on_skin_button_pressed", ["10"])
	# warning-ignore:return_value_discarded
	$skin11.connect("pressed", self, "_on_skin_button_pressed", ["11"])
	# warning-ignore:return_value_discarded
	$skin12.connect("pressed", self, "_on_skin_button_pressed", ["12"])
	
func _on_skin_button_pressed(number):
	emit_signal("changeSkin", number)
