extends Control

var color = 1
var net

func _ready():
	for i in $buttons.get_children():
		i.connect("pressed", self, "changeColor", [i.name])
	net = get_tree().get_root().get_node("Start").network
	net.connect("color_taken", self, "update_colors")
	update_colors()
func changeColor(newcolor):
	color = newcolor
	update_colors()
	get_tree().get_root().get_node("Start").network.request_color_change(int(color))
	
func update_colors():
	print(net.taken_colors)
	for i in $buttons.get_children():
		if net.is_color_taken(int(i.name)) && !i.name == str(color):
			$iksy.get_node(i.name).modulate = Color(0, 0, 0, 1)
			i.disabled = true
		else:
			$iksy.get_node(i.name).modulate = Color(0, 0, 0, 0)
			i.disabled = false
	clear_modulate()
	$buttons.get_node(str(color)).modulate = Color(0.43, 0.43, 0.43)
func clear_modulate():
	for i in $buttons.get_children():
		i.modulate = Color(1, 1, 1)
