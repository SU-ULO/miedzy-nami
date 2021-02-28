extends Control

var colorsIn = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Button_pressed(extra_arg_0):
	if $Button.pressed:
		colorsIn +=1
		if colorsIn > 1:
			$wynik.color /= colorsIn
			$wynik.color *= (colorsIn - 1)
		else:
			$wynik.color -= extra_arg_0
	else:
		$wynik.color += extra_arg_0
	print($wynik.color)

func _on_Button2_pressed(extra_arg_0):
	if $Button2.pressed:
		$wynik.color -= extra_arg_0
	else:
		$wynik.color += extra_arg_0


func _on_Button3_pressed(extra_arg_0):
	if $Button3.pressed:
		$wynik.color -= extra_arg_0
	else:
		$wynik.color += extra_arg_0
