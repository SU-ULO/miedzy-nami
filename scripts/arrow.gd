extends Node2D

# calls teleport function on vent that arrow is child of
# after being pressed by player (keyboard bindings still to do)

var link = null
var body = null
var child_number = 0

func call_teleport():
	if link == null:
		print("ERROR: no vent conected to button")
	else: if body == null:
		print("ERROR: no body to teleport")
	else:
		get_parent().get_parent().teleport(body, link)

func _on_arrow_button_down():
	call_teleport()

func _on_arrow_mouse_entered():
	get_parent().get_parent().arrowHighlight(child_number)

func _on_arrow_mouse_exited():
	get_parent().get_parent().arrowHighlight()
