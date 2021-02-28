extends TextureButton

var running = false

signal decrement

func _ready():
	pass # Replace with function body.



func _on_arr_down_button_down():
	running = true
	emit_signal("decrement")
	get_parent().get_node("Timer3").start()
	yield(get_parent().get_node("Timer3"), "timeout")
	while running:
		emit_signal("decrement")
		get_parent().get_node("Timer4").start()
		yield(get_parent().get_node("Timer4"), "timeout")

func _on_arr_down_button_up():
	running = false
