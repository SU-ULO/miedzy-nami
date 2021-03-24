extends StaticBody2D

var players
var rooms = {}
var opened = false
var players_count = {}

onready var map_res = load("res://gui/admin.tscn")
onready var player_icon_res = load("res://gui/podsceny/admin_player.tscn")
onready var canvas = get_owner().get_node("CanvasLayer")
var map = null

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
		if map != null:
			update_map()

func update_map():
	# hot mess but who cares :)
	
	var path
	for data in players_count.keys():
		path = "rooms/" + data
		
		for child in map.get_node(path).get_children():
			child.queue_free()
		
		for _iter in range(players_count[data]):
			map.get_node(path).add_child(player_icon_res.instance())


func Interact(_body):
	opened = true
	map = map_res.instance()
	canvas.add_child(map)
	
func EndInteraction(_body):
	map.queue_free()
	map = null
	opened = false

func in_room(who, room):
	return room[0].x < who.global_position.x && room[0].y < who.global_position.y && room[1].x > who.global_position.x && room[1].y > who.global_position.y

