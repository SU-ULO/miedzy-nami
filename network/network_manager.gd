extends Node

class_name NetworkManager

var world := preload('res://scenes/school.tscn').instance()
var player_characters := Dictionary()
var own_player = null
var own_id := 0
var server_key := ""

# warning-ignore:unused_signal
signal joined_room()
# warning-ignore:unused_signal
signal left_room()

signal meeting_start()

func create_world(config):
	server_key = config.key
	add_child(world)

func display_key(key):
	server_key = key

func request_meeting(_dead: int):
	pass

func start_meeting(caller: int, dead: int):
	own_player.disabled_movement = true
	own_player.position = world.get_node("Mapa/dekoracje/meeting-table").get_child(own_id).global_position
	var gui = load("res://gui/meeting/meetingGUI.tscn").instance()
	var playerbox = load("res://gui/meeting/PalyerMeetingBox.tscn")
	
	for player in player_characters.keys():
		var box = playerbox.instance()
		box.connect("chosen", self, "set_chosen")
		box.id = player
		box.get_node("Button/Label").text = player_characters[player].username
		if(player % 2 == 0):
			gui.get_node("H/V1").add_child(box)
		else:
			gui.get_node("H/V2").add_child(box)
	
	own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("TaskPanel")
	own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("ActionButtons")
	own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("TopButtons")
	if own_player.is_in_group("impostors"):
		own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("impostor")
	
	world.get_node("CanvasLayer").add_child(gui)
	
	print("meeting started by "+String(caller)+" corpse belongs to "+String(dead))
	emit_signal("meeting_start")

func request_kill(_dead: int):
	pass

func kill(dead: int, pos: Vector2):
	if player_characters.has(dead):
		player_characters[dead].turn_into_corpse(pos)

func set_chosen(id):
	#powiedz serwerowi że wybrałeś gracza
	world.get_node("CanvasLayer").get_child(0).chosen = id


