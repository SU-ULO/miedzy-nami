extends Control


func _ready():
	#if player is room admin
	#$buttons/game.visible = true
	
	for i in $buttons.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "showMenu", [i.name])
	
func hideAll():
	for i in $menus.get_children():
		i.visible = false

func showMenu(name):
	hideAll()
	$menus.get_node(name + "-menu").visible = true
	
