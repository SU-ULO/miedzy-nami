extends Control

func _close():
	get_parent().get_parent().clear_canvas()

func _exit():
	get_tree().get_root().get_node("Start").leave_room()
