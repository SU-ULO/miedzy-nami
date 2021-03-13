extends NetworkManager

class_name ServerNetworkManager

func _ready():
	pass

func create_client(config):
	print(config)

func create_world(config):
	.create_world(config)
	own_player = preload("res://entities/player.tscn").instance()
	world.get_node('Mapa/YSort').add_child(own_player)
	emit_signal("joined_room")
