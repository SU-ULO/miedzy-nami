extends StaticBody2D

var loadingscreen = preload("res://gui/loadingscreen.tscn")
var x
var heh

func _ready():
	add_to_group("entities")
	add_to_group("interactable")

func get_heh():
	heh = get_tree().get_root().get_node("Start").network.own_player

func Interact(body):
	heh = body
	var net = get_tree().get_root().get_node("Start").network
	if body.owner_id==0 and net.gamestate == 0:
			net.request_game_start()
	return false

func display_start_ui():
	get_heh()
	x = loadingscreen.instance()
	x.connect("finish", self, "letsgo")
	heh.get_node("CanvasLayer/playerGUI").visible = false
	heh.get_parent().get_parent().get_parent().get_node("CanvasLayer").add_child(x)

func EndInteraction(_body):
	pass

func letsgo():
	x.disconnect("finish", self, "letsgo")
	x.queue_free()
	heh.get_node("CanvasLayer/playerGUI").visible = true
	heh.currentInteraction = null
