extends TextureButton

var rotating = false
var lastx = 0;
var obroty = 0

var niewiem = 80.0
var halohalo = 0
func _ready():
	pass

func _process(_delta):
	if rotating:
		var x = (((get_parent().get_parent().rect_position + get_parent().rect_position + rect_position + rect_pivot_offset).angle_to_point(get_viewport().get_mouse_position()) * 180 )/ PI)
		rect_rotation = x
		if lastx > 170 && x < -170:
			obroty+=1
		if lastx < -170 && x > 170:
			obroty-=1
		lastx = x
		
		halohalo = float(x + obroty * 360) / niewiem
		
func _on_guzik_button_down():
	rotating = true


func _on_guzik_button_up():
	rotating = false
