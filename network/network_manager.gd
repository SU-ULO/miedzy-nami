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
	"long-tasks": 15,
	"short-tasks": 15
}

var colors := {
	1: "#894d36",
	2: "#111315",
	3: "#cdd9e2",
	4: "#c80b29",
	5: "#fe5275",
	6: "#ff943f",
	7: "#ffe462",
	8: "#377a2f",
	9: "#bc3abc",
	10: "#76e754",
	11: "#00d2a6",
	12: "#00a9e3",
	13: "#004b93",
	14: "#5c358d"
}
var camera_users_count := 0
var taken_colors := 0
var comms_disabled = 0

# warning-ignore:unused_signal
signal joined_room()
# warning-ignore:unused_signal
signal left_room()

signal meeting_start()

signal gui_sync(gui_name, gui_data)

signal color_taken()

signal sabotage(type)

signal sabotage_end(type)

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
# warning-ignore:return_value_discarded
	connect("sabotage", world.get_node("Mapa/YSort/telewizorek"), "check_on")
# warning-ignore:return_value_discarded
	connect("sabotage_end", world.get_node("Mapa/YSort/telewizorek"), "check_off")
# warning-ignore:return_value_discarded
	connect("sabotage", world.get_node("Mapa/YSort/electrical"), "check_on")
# warning-ignore:return_value_discarded
	connect("sabotage_end", world.get_node("Mapa/YSort/electrical"), "check_off")

func display_key(key):
	server_key = key

func request_meeting(_dead: int):
	pass

func start_meeting(caller: int, dead: int):
	var rips = []
	
	if own_player.currentInteraction != null:
		if own_player.currentInteraction.is_in_group("tasks"):
			own_player.currentInteraction.EndInteraction()
		else:
			own_player.currentInteraction.EndInteraction(own_player)
			
	own_player.disabled_movement = true
	recalculate_pos()
	
	own_player.position = world.get_node("Mapa/YSort/meeting-table").get_child(own_id).global_position
	var gui = load("res://gui/meeting/meetingGUI.tscn").instance()
	var playerbox = load("res://gui/meeting/PalyerMeetingBox.tscn")
	
	var iter = 0
	for player in player_characters.keys():
		if player_characters[player].is_in_group("rip"):
			rips.push_back(player)
		else:
			var box = playerbox.instance()
			box.connect("chosen", self, "set_chosen")
			box.id = player
			box.color = colors[player_characters[player].color] #get_playercolor ???
			box.get_node("Button/L").text = player_characters[player].username
			gui.get_node("H/V" + String(iter%2 + 1)).add_child(box)
			iter += 1
	
	for rip in rips:
		var box = playerbox.instance()
		box.connect("chosen", self, "set_chosen")
		box.id = rip
		box.color = colors[player_characters[rip].color] #get_playercolor ???
		box.get_node("Button/L").text = player_characters[rip].username
		gui.get_node("H/V" + String(iter%2 + 1)).add_child(box)
		box.get_node("Button").get_stylebox("disabled", "").bg_color = Color("#2874A6")
		iter += 1
	
	gui.set_all_buttons(0)
	var skip = gui.get_node("S")
	skip.connect("chosen", self, "set_chosen")
	gui.connect("meeting_state_changed", self, "set_meeting_state")
	own_player.get_node("CanvasLayer/playerGUI").setVisibility("self", 0)
	
	world.get_node("CanvasLayer").add_child(gui)
	gui.time = gamesettings["discussion-time"]
	gui.set_all_buttons(0)
	
	print("meeting started by "+String(caller)+" corpse belongs to "+String(dead))
	emit_signal("meeting_start")

func set_meeting_state(state):
	var gui = world.get_node("CanvasLayer").get_child(0)
	
	if state == 1:
		if own_player.is_in_group("rip") == false:
			for player in player_characters.keys():
				if player_characters[player].is_in_group("rip") == false:
					gui.get_player_box(player).get_node("Button").disabled = false
			gui.get_node("S").disabled = false
			
		gui.time = gamesettings["voting-time"]
		gui.label_text = "Koniec głosowania za: "
		gui.meeting_state += 1
	if state == 2:
		gui.queue_free()
		own_player.disabled_movement = false
		own_player.get_node("CanvasLayer/playerGUI").setVisibility("self", 1)
		
func update_meeting():
	#stuff for updating meeting ui, don't know what is needed for this
	pass

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
				c.visible = true

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
		world.get_node("CanvasLayer/BG/S").set_vote(color)
	
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

func request_color_change(_color: int):
	pass

func handle_colors_change(taken: int, players: Dictionary):
	taken_colors=taken
	for p in players:
		if player_characters.has(p):
			player_characters[p].color = players[p]
			player_characters[p].get_node("sprites").loadLook()
	emit_signal("color_taken")

func request_set_look(look: Dictionary):
	pass

func set_look(id: int, look: Dictionary):
	if player_characters.has(id):
		player_characters[id].currLook.set_look(look)
		player_characters[id].get_node("sprites").loadLook()

func request_set_invisible(_id, _val: bool):
	pass

func set_invisible(id, val: bool):
	if id == own_id:			
		own_player.get_node("sprites").visible = val
		own_player.get_node("Label").visible = val
		own_player.get_node("PlayerHitbox").visible = val
	else:
		player_characters[id].visible = val
