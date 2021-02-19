extends TextureButton

var rotating = false

func _ready():
	pass
	
func _process(_delta):
	if rotating:
		rect_rotation = (((get_parent().rect_position + rect_position + rect_pivot_offset).angle_to_point(get_viewport().get_mouse_position()) * 180 )/ PI + 180)
func _on_guzik_button_down():
	rotating = true


func _on_guzik_button_up():
	rotating = false
