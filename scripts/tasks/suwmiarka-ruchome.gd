extends TextureButton

var clickDelta
var dragging = false

func _ready():
	pass
	
func _process(_delta):
	if dragging:
		rect_global_position.x = clamp(get_viewport().get_mouse_position().x - clickDelta, 205, 1500)


func _on_ruchome1_button_down():
	dragging = true
	clickDelta = (get_viewport().get_mouse_position().x - rect_global_position.x)


func _on_ruchome1_button_up():
	dragging = false
