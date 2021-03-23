extends StaticBody2D

var players
var rooms = {}
var opened = false
var players_count = {}

func _ready():
	add_to_group("interactable")
	add_to_group("entities")
	for i in get_tree().get_root().get_node('Start').network.world.get_node("rooms").get_children():
		rooms[i.name] = [i.get_node("1").global_position, i.get_node("2").global_position]
	players = get_tree().get_root().get_node('Start').network.player_characters

func _process(_delta):
	if opened:
		for i in rooms.keys():
			players_count[i] = 0
			for j in players.values():
				if in_room(j, rooms[i]):
					players_count[i]+=1
func Interact(_body):
	opened = true
	print("ej")
func EndInteraction(_body):
	opened = false

func in_room(who, room):
	return room[0].x < who.global_position.x && room[0].y < who.global_position.y && room[1].x > who.global_position.x && room[1].y > who.global_position.y

