extends TextureButton

var running = false

signal increment

func _ready():
	pass # Replace with function body.



func _on_arr_up_button_down():
	running = true
	emit_signal("increment")
	get_parent().get_node("Timer").start()
	yield(get_parent().get_node("Timer"), "timeout")
	while running:
		emit_signal("increment")
		get_parent().get_node("Timer2").start()
		yield(get_parent().get_node("Timer2"), "timeout")

func _on_arr_up_button_up():
	running = false
