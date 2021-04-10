extends Control

var meetings_left
var sabotage_on = false
var countdown = 0
signal emergency_meeting_requested()

func _ready():
	$Button.disabled = true
	start_gui()
func wait5s():
	var x
	if countdown == 0:
		x = 3
	else:
		x = int(countdown)
	for i in range(1, x):
		$Label2.text = "czekaj " + str(x - 1 - i) + "s"
		$Timer.start()
		yield($Timer, "timeout")
	$Button.disabled = false
	$Button.modulate = Color(1, 1, 1)
func start_gui():
	if sabotage_on:
		$Label.text = "Nie możesz zwołać zebrania podczas kryzysu!" 
	else:
		$Label.text = "Możesz zwołać zebranie jeszcze " + str(meetings_left) + " raz / razy" 
		if meetings_left > 0:
			wait5s()


func _on_Button_pressed():
	emit_signal("emergency_meeting_requested")
