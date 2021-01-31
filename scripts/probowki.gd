extends Control

var order:int = 0
var prev_color
var toggle:bool = true

onready var anim_1 = $AP.get_animation("napelnij")
var prob1 = false
var prob2 = false
var prob3 = false

func toggle_buttons():
	get_node("HBoxContainer/button-red").disabled = toggle
	get_node("HBoxContainer/button-blue").disabled = toggle
	get_node("HBoxContainer/button-yellow").disabled = toggle
	toggle = !toggle
	
func mix_colors(color1, color2):
	if color1 == color2: return color1
	if color1 == Color(1, 0, 0, 1) or color2 == Color(1, 0, 0, 1):
		if color1 == Color(0, 0, 1, 1) or color2 == Color(0, 0, 1, 1):
			return Color(0.5, 0, 1, 1) #purple 
		else:
			return Color(1, 0.5, 0, 1) #orange
	else:
		return Color(0, 1, 0, 1) #green


func _on_AnimationPlayer_animation_finished(_anim_name):
	toggle_buttons()

func _on_button_down(color):
	
	if color == Color(1, 0, 0, 1):
		prob1 = !prob1
	else: if color == Color(0, 0, 1, 1):
		prob2 = !prob2
	else: if color == Color(1, 1, 0, 1):
		prob3 = !prob3
	
	
	if order == 0:
		prev_color = color
		order += 1
	else: if order == 1:
		if prev_color == color:
			order -= 1
		else:
			toggle_buttons()
			var track = anim_1.find_track("AP/Polygon2D:color")
			anim_1.track_set_key_value(track, 0, mix_colors(color, prev_color))
			anim_1.track_set_key_value(track, 1, mix_colors(color, prev_color))
			$AP.play("napelnij")
			if prob1: $probowka1.anim()
			if prob2: $probowka2.anim()
			if prob3: $probowka3.anim()
			order += 1
	else:
		get_node("AP/Polygon2D").visible = 0
		order = 0
		prob1 = false; prob2 = false; prob3 = false
		$probowka1.reset()
		$probowka2.reset()
		$probowka3.reset()
		
