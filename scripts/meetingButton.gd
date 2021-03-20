extends Control

var id
signal chosen(id)

func _on_Control_pressed():
	emit_signal("chosen", id)
