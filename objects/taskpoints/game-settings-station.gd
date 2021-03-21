extends StaticBody2D


var menu
var lookMenu
var colorMenu
var game_settings

func _ready():
	add_to_group("entities")
	add_to_group("interactable")
	
func Interact(body):
	menu = load("res://gui/game settings/game customisation menu.tscn").instance()
	get_owner().get_node("CanvasLayer").add_child(menu)
	if body.owner_id == 0:
		menu.get_node("buttons/game").visible = true
	lookMenu = menu.get_node("menus/look-menu")
	lookMenu.currLook = body.currLook
	lookMenu.refresh()
	colorMenu = menu.get_node("menus/color-menu")
	colorMenu.color = body.color
	#game_setting = body.game_settings or sth; idk where are they stored
	#now load them (i will do it tomorrow)
func EndInteraction(body):
	body.color = colorMenu.color
	body.currLook = lookMenu.currLook
	game_settings = menu.get_node("menus/game-menu").get_settings()
	print(game_settings) # and apply them or copy somewhere
	body.get_node("sprites").loadLook()
	get_owner().get_node("CanvasLayer").remove_child(menu)
