extends Node2D

const radius:float = 500.0
const elipsefy:float = 1.4

func teleport_players():
	# client side teleportation, for now get tree because 
	# I dont have better idea, probably not working
	
	var alive_players = get_tree().get_nodes_in_group("players")
	var player_count = alive_players.size()
	var angle = 2*PI/player_count
	
	var new_pos
	var new_angle = 0
	
	for player in alive_players:
		new_angle += angle
		new_pos = Vector2(get_parent().position.x + radius * cos(new_angle) * elipsefy, get_parent().position.y + radius * sin(new_angle))
		player.position = new_pos
