extends Control

var color

func _ready():
	for i in $GridContainer.get_children():
		i.connect("pressed", self, "changeColor", [i.name])
		
func changeColor(newcolor):
	color = newcolor
	get_tree().get_root().get_node("Start").network.request_color_change(int(color))
