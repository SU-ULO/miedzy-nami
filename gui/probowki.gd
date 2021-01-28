extends Control

var order:int = 0
var track
var prev_color
var toggle:bool = true
onready var anim_1 = $AP.get_animation("napelnij")
onready var anim_2 = $AP.get_animation("napelnij2")

func toggle_buttons():
	get_node("HBoxContainer/button-red").disabled = toggle
	get_node("HBoxContainer/button-blue").disabled = toggle
	get_node("HBoxContainer/button-yellow").disabled = toggle
	toggle = !toggle
	
func mix_colors(color1, color2):
	if color1 == Color(1, 0, 0, 1) or color2 == Color(1, 0, 0, 1):
		if color1 == Color(0, 0, 1, 1) or color2 == Color(0, 0, 1, 1):
			return Color(0.5, 0, 1, 1) #purple 
		else:
			return Color(1, 0.5, 0, 1) #orange
	else:
		return Color(0, 1, 0, 1) #green


func _on_AnimationPlayer_animation_finished(_anim_name):
	toggle_buttons()
	order += 1

func _on_button_down(color):
	if order == 0:
		toggle_buttons()
		track = anim_1.find_track("AP/Polygon2D:color")
		anim_1.track_set_key_value(track, 0, color)
		anim_1.track_set_key_value(track, 1, color)
		$AP.play("napelnij")
		prev_color = color
	else: if order == 1:
		toggle_buttons()
		track = anim_2.find_track("AP/Polygon2D:color")
		anim_2.track_set_key_value(track, 0, prev_color)
		anim_2.track_set_key_value(track, 1, mix_colors(prev_color, color))
		$AP.play("napelnij2")
	else:
		get_node("AP/Polygon2D").visible = 0
		order = 0
		
