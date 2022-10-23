extends Control

var colors = [Color(0, 0, 0), Color(0, 1, 0), Color(0.5, 0, 1), Color(1, 0.5, 0)]
var cel

func _ready():
	colors.shuffle()
	cel = colors.front()
	$cel/shape.color = cel
	# warning-ignore:return_value_discarded
	$r.connect("pressed", self, "changeColor")
	# warning-ignore:return_value_discarded
	$y.connect("pressed", self, "changeColor")
	# warning-ignore:return_value_discarded
	$b.connect("pressed", self, "changeColor")
	
func colorMafs(x):
	match x:
		[0, 0, 0]:
			#biały
			return Color(1, 1, 1)
		[0, 0, 1]:
			#niebieski
			return Color(0, 0, 1)
		[0, 1, 0]:
			#zolty
			return Color(1, 1, 0)
		[0, 1, 1]:
			#zielony
			return Color(0, 1, 0)
		[1, 0, 0]:
			#czerwony
			return Color(1, 0, 0)
		[1, 0, 1]:
			#fioletowy
			return Color(0.5, 0, 1)
		[1, 1, 0]:
			#pomaranczowy
			return Color(1, 0.5, 0)
		[1, 1, 1]:
			#czarny
			return Color(0, 0, 0)
			
func changeColor():
	if $r.pressed:
		$r.modulate = Color(0.1, 0.1, 0.1, 1)
	else:
		$r.modulate = Color(1, 1, 1, 1)
	if $y.pressed:
		$y.modulate = Color(0.1, 0.1, 0.1, 1)
	else:
		$y.modulate = Color(1, 1, 1, 1)
	if $b.pressed:
		$b.modulate = Color(0.1, 0.1, 0.1, 1)
	else:
		$b.modulate = Color(1, 1, 1, 1)
	$wynik.stop()
	$wynik.get_animation("change color").track_set_key_value(0, 0, $wynik/wynik.color)
	$wynik.get_animation("change color").track_set_key_value(0, 1, colorMafs([int($r.pressed), int($y.pressed), int($b.pressed)]))
	$wynik.play("change color")


func _on_wynik_animation_finished(_anim_name):
	if cel == $wynik/wynik.color:
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
