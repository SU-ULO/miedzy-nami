extends Control

var greenlamp = preload("res://textures/lampgreen.svg")
var redlamp = preload("res://textures/lampred.svg")
var colors = [Color("#b92121"), Color("#e27e1e"), Color("#298729"), Color("#3339a3")]

func _ready():
	randomize();
	
	# bo nie ma do while
	var rand = true
	while(rand):
		randomize_colors()
		set_lamps()
		if(!check_win()): rand = false
			
func randomize_colors():

	colors.shuffle()

	$button1.set_colorr(colors[0])
	$button2.set_colorr(colors[1])
	$button3.set_colorr(colors[2])
	$button4.set_colorr(colors[3])
	
	colors.shuffle()
	
	$flatbutton1.set_colorr(colors[0])
	$flatbutton2.set_colorr(colors[1])
	$flatbutton3.set_colorr(colors[2])
	$flatbutton4.set_colorr(colors[3])
	
func set_lamps():
	if $button1.get_colorr() == $flatbutton1.get_colorr():
		$lamp1.set_texture(greenlamp)
	else:
		$lamp1.set_texture(redlamp)
	if $button2.get_colorr() == $flatbutton2.get_colorr():
		$lamp2.set_texture(greenlamp)
	else:
		$lamp2.set_texture(redlamp)
	if $button3.get_colorr() == $flatbutton3.get_colorr():
		$lamp3.set_texture(greenlamp)
	else:
		$lamp3.set_texture(redlamp)
	if $button4.get_colorr() == $flatbutton4.get_colorr():
		$lamp4.set_texture(greenlamp)
	else:
		$lamp4.set_texture(redlamp)

func check_win():
	if $lamp1.get_texture() == greenlamp:
		if $lamp2.get_texture() == greenlamp:
			if $lamp3.get_texture() == greenlamp:
				if $lamp4.get_texture() == greenlamp:
					return true
	return false

var toggle :bool = 1
var prev

func _on_button_clicked(button):
	var temp
	
	if toggle:
		prev = button
	else:
		if(prev != button):
			temp = button.get_colorr()
			button.set_colorr(prev.get_colorr())
			prev.set_colorr(temp)
			$Timer.start()
			yield($Timer, "timeout")
			button.press(true)
			prev.press(true)
	toggle = !toggle
	set_lamps()
	if check_win(): 
		print("you won lol")
		# end task
