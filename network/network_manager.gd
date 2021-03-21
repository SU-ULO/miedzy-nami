extends Node

class_name NetworkManager

enum {LOBBY, STARTED, MEETING}
var gamestate := LOBBY
var gamestate_params = null

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
	var rips = []
	own_player.disabled_movement = true
	recalculate_pos()
	own_player.position = world.get_node("Mapa/dekoracje/meeting-table").get_child(own_id).global_position
	var gui = load("res://gui/meeting/meetingGUI.tscn").instance()
	var playerbox = load("res://gui/meeting/PalyerMeetingBox.tscn")
	
	for player in player_characters.keys():
		if player_characters[player].is_in_group("rip"):
			rips.push_back(player)
		else:
			var box = playerbox.instance()
			box.connect("chosen", self, "set_chosen")
			box.id = player
			box.color = "#00FF00" #get_playercolor ???
			box.get_node("Button/L").text = player_characters[player].username
			if(player % 2 == 0):
				gui.get_node("H/V1").add_child(box)
			else:
				gui.get_node("H/V2").add_child(box)
	
	# handle rips
	for player in rips:
		var box = playerbox.instance()
		box.connect("chosen", self, "set_chosen")
		box.id = player
		box.get_node("Button/L").text = player_characters[player].username
		if(player % 2 == 0):
			gui.get_node("H/V1").add_child(box)
		else:
			gui.get_node("H/V2").add_child(box)
		box.get_node("Button").disabled = true
	
	if own_player.is_in_group("rip"):
		gui.disable_all()
	var skip = gui.get_node("S")
	skip.connect("chosen", self, "set_chosen")
	
	own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("TaskPanel")
	own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("ActionButtons")
	own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("TopButtons")
	if own_player.is_in_group("impostors"):
		own_player.get_node("CanvasLayer/playerGUI").toggleVisibility("impostor")
	
	world.get_node("CanvasLayer").add_child(gui)
	
	print("meeting started by "+String(caller)+" corpse belongs to "+String(dead))
	emit_signal("meeting_start")

func recalculate_pos():
	var radius:float = 500.0
	var elipsyfy:float = 1.5
	var alive = 0
	
	for player in player_characters.keys():
		if !player_characters[player].is_in_group("rip"):
			alive += 1
	
	var spawn = world.get_node("Mapa/dekoracje/meeting-table/spawnpositions")
	var angle = 2*PI/alive
	var a = 0
	var pos = spawn.position
	for point in spawn.get_children():
		a += angle
		point.position = Vector2(pos.x + radius * cos(a) * elipsyfy, pos.y + radius * sin(a))

func request_kill(_dead: int):
	pass

func kill(dead: int, pos: Vector2):
	if player_characters.has(dead):
		player_characters[dead].turn_into_corpse(pos)

func set_chosen(id):
		world.get_node("CanvasLayer").get_child(0).chosen = id
		add_vote(own_id, id)

func add_vote(voter_id, voted_id):
	# powiedz serwerowi że gracz wybrał gracza
	
	#głos
	var color = "#FF0000" #var color = voter_id cośtam color ???
	if voted_id >= 0:
		var box = world.get_node("CanvasLayer").get_child(0).get_player_box(voted_id)
		box.set_vote(color)
	elif voted_id == -1:
		var box = world.get_node("CanvasLayer/BG/S").set_vote(color)
	
	#oddano głos
	var voter_box = world.get_node("CanvasLayer").get_child(0).get_player_box(voter_id)
	voter_box.set_voted()

func get_spawn_position(id: int) -> Vector2:
	if world:
		if gamestate==LOBBY:
			return world.get_node("lobby-position").global_position
		else:
			return world.get_node("Mapa/dekoracje/meeting-table/spawnpositions/%s" % id).global_position
	return Vector2(0, 0)

func game_start(params):
	recalculate_pos()
	for i in params["imp"]:
		if player_characters.has(i):
			#make impostor
			pass
	for c in player_characters:
		player_characters[c].global_position = get_spawn_position(c)
