extends Panel

var chosen = -1 setget set_chosen
var path

func set_chosen(id):
	if id % 2 == 0:
		path = "H/V1"
	else: 
		path = "H/V2"
	
	for player in get_node(path).get_children():
		if player.id == id:
			player.modulate = Color("#FF0000")
	disable_all()

func disable_all():
	
	for player in get_node("H/V1").get_children():
		player.get_node("Button").disabled = true
		
	for player in get_node("H/V2").get_children():
		player.get_node("Button").disabled = true
