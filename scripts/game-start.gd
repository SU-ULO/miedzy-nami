extends StaticBody2D

var heh

func _ready():
	add_to_group("entities")

func get_heh():
	heh = get_tree().get_root().get_node("Start").network.own_player

func Interact(body):
	heh = body
	var net = get_tree().get_root().get_node("Start").network
	if body.owner_id==0 and net.gamestate == 0:
			net.request_game_start()
	return false

func EndInteraction(_body):
	pass
