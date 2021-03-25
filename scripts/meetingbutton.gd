extends Control

var meetings_left
signal emergency_meeting_requested()

func _ready():
	$Button.disabled = true
	start_gui()
func wait5s():
	for i in range(0, 5):
		$Label2.text = "czekaj " + str(4 - i) + "s"
		$Timer.start()
		yield($Timer, "timeout")
	$Button.disabled = false
func start_gui():
	$Label.text = "Możesz zwołać zebranie jeszcze " + str(meetings_left) + " raz / razy" 
	if meetings_left > 0:
		wait5s()


func _on_Button_pressed():
	emit_signal("emergency_meeting_requested")
