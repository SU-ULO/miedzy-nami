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
	lookMenu.currLook.set_look(body.currLook.get_look())
	lookMenu.refresh()
	colorMenu = menu.get_node("menus/color-menu")
	colorMenu.color = body.color
	colorMenu.update_colors()
	var net = get_tree().get_root().get_node("Start").network
	if net.own_player.owner_id==0:
		menu.get_node("menus/game-menu").set_settings(net.gamesettings)
func EndInteraction(body):
	body.currLook.set_look(lookMenu.currLook.get_look())
	game_settings = menu.get_node("menus/game-menu").get_settings()
	var net = get_tree().get_root().get_node("Start").network
	if net.own_player.owner_id==0:
		net.set_game_settings(game_settings)
	body.get_node("sprites").loadLook()
	get_owner().get_node("CanvasLayer").remove_child(menu)
