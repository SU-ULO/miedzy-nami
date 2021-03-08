extends StaticBody2D


var menu
var lookMenu

func _ready():
	add_to_group("entities")
	add_to_group("interactable")
	
func Interact(body):
	menu = load("res://gui/game settings/game customisation menu.tscn").instance()
	get_owner().get_node("CanvasLayer").add_child(menu)
	lookMenu = menu.get_node("menus/look-menu")
	lookMenu.currLook = body.currLook
	lookMenu.refresh()

func EndInteraction(body):
	body.currLook = lookMenu.currLook
	body.loadLook()
	get_owner().get_node("CanvasLayer").remove_child(menu)
