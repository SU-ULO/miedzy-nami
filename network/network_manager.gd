extends Node

class_name NetworkManager

enum {LOBBY, STARTED, MEETING}
var gamestate := LOBBY
var gamestate_params = null

const preloadedmap := preload('res://scenes/school.tscn')
const Task := preload("res://scripts/tasks/Task.cs")

var world = null
var player_characters := Dictionary()
var own_player = null
var own_id := 0
var server_key := ""
var gamesettings := {
	"impostor-count": 2,
	"comfirm-ejects": true,
	"meeting-count": 1,
	"anonnymous-votes": true,
	"emergency-cooldown": 15,
	"discussion-time": 15,
	"voting-time": 120,
	"player-speed": 1,
	"crewmate-vision": 1,
	"impostor-vision": 1,
	"kill-cooldown": 45,
	"kill-distance": 1,
	"taskbar-updates": 1,
	"long-tasks": 1,
	"short-tasks": 3
}

var camera_users_count := 0
var taken_colors := 0

# warning-ignore:unused_signal
signal joined_room()
# warning-ignore:unused_signal
signal left_room()

signal meeting_start()

func is_color_taken(c: int):
	return taken_colors & 1<<c

func set_color_taken(c: int):
	taken_colors |= 1<<c

func unset_color_taken(c: int):
	taken_colors &= ~(1<<c)

func get_free_color_and_set():
	for i in range(14):
		if !is_color_taken(i+1):
			set_color_taken(i+1)
			return i+1
	return 0

func create_world(config):
	server_key = config.key
	load("res://scripts/tasks/Task.cs").ClientCleanup()
	world = preloadedmap.instance()
	add_child(world)

func display_key(key):
	server_key = key

func request_meeting(_dead: int):
	pass

func start_meeting(caller: int, dead: int):
	var rips = []
	own_player.disabled_movement = true
	recalculate_pos()
	own_player.position = world.get_node("Mapa/YSort/meeting-table").get_child(own_id).global_position
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
	
	var spawn = world.get_node("Mapa/YSort/meeting-table/spawnpositions")
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
		var killed = player_characters[dead]
		killed.turn_into_corpse(pos)
		if own_player.dead:
			for c in player_characters.values():
				c.visible=true

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
			return world.get_node("Mapa/YSort/meeting-table/spawnpositions/%s" % id).global_position
	return Vector2(0, 0)

func game_start(params, taskstuff):
	var Task := load("res://scripts/tasks/Task.cs")
	recalculate_pos()
	for i in params["imp"]:
		if player_characters.has(i):
			#make impostor
			pass
	for t in taskstuff:
		var task = Task.GetTaskByID(t)
		task.local=true
		own_player.localTaskList.append(task)
	for c in player_characters:
		player_characters[c].global_position = get_spawn_position(c)

func request_cameras_enable(_on_off: bool):
	pass

func cameras_enable(on_off: bool): #0 for leave, 1 for join
	if on_off == false:
		camera_users_count-=1
	else:
		camera_users_count+=1
	if camera_users_count > 0:
		world.get_node("Mapa/camera1").cam_enable()
		world.get_node("Mapa/camera2").cam_enable()
		world.get_node("Mapa/camera3").cam_enable()
		world.get_node("Mapa/camera4").cam_enable()
	else:
		world.get_node("Mapa/camera1").cam_disable()
		world.get_node("Mapa/camera2").cam_disable()
		world.get_node("Mapa/camera3").cam_disable()
		world.get_node("Mapa/camera4").cam_disable()

func handle_game_settings(settings):
	gamesettings = settings
	apply_settings_to_player()

func apply_settings_to_player():
	own_player.player_speed = own_player.default_speed * gamesettings["player-speed"]
