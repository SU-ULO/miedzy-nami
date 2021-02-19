extends Control

signal changeSkin(number)

func _ready():
	$skin1.connect("pressed", self, "_on_skin_button_pressed", ["1"])
	$skin2.connect("pressed", self, "_on_skin_button_pressed", ["2"])
	$skin3.connect("pressed", self, "_on_skin_button_pressed", ["3"])
	$skin4.connect("pressed", self, "_on_skin_button_pressed", ["4"])
	$skin5.connect("pressed", self, "_on_skin_button_pressed", ["5"])
	$skin6.connect("pressed", self, "_on_skin_button_pressed", ["6"])
	$skin7.connect("pressed", self, "_on_skin_button_pressed", ["7"])
	$skin8.connect("pressed", self, "_on_skin_button_pressed", ["8"])
	$skin9.connect("pressed", self, "_on_skin_button_pressed", ["9"])
	$skin10.connect("pressed", self, "_on_skin_button_pressed", ["10"])
	$skin11.connect("pressed", self, "_on_skin_button_pressed", ["11"])
	$skin12.connect("pressed", self, "_on_skin_button_pressed", ["12"])
	
func _on_skin_button_pressed(number):
	emit_signal("changeSkin", number)
