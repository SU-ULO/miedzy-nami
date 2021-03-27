extends Node

class_name NetworkManager

enum {LOBBY, STARTED, MEETING, ENDED}
var gamestate := LOBBY
var gamestate_params = null

var currentconfig

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

var current_votes = {}

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
	currentconfig=config
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
	if own_id == 0:
		world.get_node("Mapa/lobby/start").add_to_group("interactable")
func recreate_world():
	world.queue_free()
	player_characters.clear()
	own_player=null
	create_world(currentconfig)

func display_key(key):
	server_key = key

func request_meeting(_dead: int):
	pass

func start_meeting(caller: int, dead: int):
	var rips = []
	
	#end all interactions
	if own_player.currentInteraction != null:
		if own_player.currentInteraction.is_in_group("tasks"):
			own_player.currentInteraction.EndInteraction()
		else:
			own_player.currentInteraction.EndInteraction(own_player)
		own_player.currentInteraction = null
		own_player.get_node("CanvasLayer2/exit_button").visible = false
	#get rid of all the bodies
	for i in world.get_tree().get_nodes_in_group("deadbody"):
		i.queue_free()
	#disable movement and calculate teleport positions
	own_player.disabled_movement = true
	recalculate_pos()
	
	own_player.position = get_spawn_position(own_id)
	var gui = load("res://gui/meeting/meetingGUI.tscn").instance()
	var playerbox = load("res://gui/meeting/PlayerMeetingBox.tscn")
	
	var iter = 0
	# for every player
	for player in player_characters.keys():
		if player_characters[player].is_in_group("rip"):
			rips.push_back(player) # if dead then handle later
		else:
			var box = playerbox.instance() #make box in meeting gui
			
			#set box atributes
			box.connect("chosen", self, "set_chosen")
			box.id = player
			box.color = Color(colors[player_characters[player].color])
			box.get_node("Button/L").text = player_characters[player].username
			
			# put it in right place
			gui.get_node("H/V" + String(iter%2 + 1)).add_child(box)
		
			iter += 1
	
	for rip in rips: # now same for rips because we want them last on list
		var box = playerbox.instance()

		box.connect("chosen", self, "set_chosen")
		box.id = rip
		box.color =  Color(colors[player_characters[rip].color])
		box.get_node("Button/L").text = player_characters[rip].username

		gui.get_node("H/V" + String(iter%2 + 1)).add_child(box)
		# aslo different color cause they dead
		box.get_node("Button").get_stylebox("disabled", "").bg_color = Color("#2874A6")
		iter += 1
	
	#now we disable all butons because no one can vote in discussion time
	gui.time = gamesettings["discussion-time"]
	gui.set_all_buttons(0)
	var skip = gui.get_node("S")

	#connect "click" signal to skip button and signal to change meeting state to voting time
	skip.connect("chosen", self, "set_chosen")
	gui.connect("meeting_state_changed", self, "set_meeting_state")
	
	#turn off all player gui
	own_player.get_node("CanvasLayer/playerGUI").setVisibility("self", 0)
	
	# show gui on screen
	world.get_node("CanvasLayer").add_child(gui)

	
	print("meeting started by "+String(caller)+" corpse belongs to "+String(dead))
	emit_signal("meeting_start")

func set_meeting_state(state): # func to toggle from discussion time to voting time and to reveal results
	var gui = world.get_node("CanvasLayer").get_child(0) #get gui
	gui.meeting_state += 1
	
	if state == 1: # voting starts
		if own_player.is_in_group("rip") == false: # if player is dead then wi dont need to do anything
			for player in player_characters.keys(): # otherwise for every alive player we anable their button
				if player_characters[player].is_in_group("rip") == false:
					gui.get_player_box(player).get_node("Button").disabled = false
			gui.get_node("S").disabled = false # also skip button
		
		#set time and label
		gui.time = gamesettings["voting-time"]
		gui.label_text = "Koniec głosowania za: "
	
	if state == 2: # voting ended
		#show votes
		for box in gui.get_node("H/V1").get_children():
			box.set_vote_visibility(1)
			
		for box in gui.get_node("H/V2").get_children():
			box.set_vote_visibility(1)
			
		#determin meeting "winner"
		
		var votes = {}
		# count votes
		for vote in current_votes:
			if !votes.has(vote): votes[vote] = 1
			else:votes[vote] += 1
		# find max
		var best = 0
		var best_id = -1
		
		for key in votes.keys():
			if votes[key] > best:
				best = votes[key]
				best_id = key
			elif votes[key] == best:
				best_id = -1
				
		# count alive impostors
		var imps = 0
		for imp in get_tree().get_nodes_in_group("impostors"):
			if !imp.is_in_group("rip"):
				imps += 1
				
		# show votes
		if best_id == -1 or !player_characters.has(best_id):
			gui.show_votes(null, imps)
		else:
			gui.show_votes(player_characters[best_id], imps)
	if state == 3: # show verdict
		gui.show_verdict()

func end_meeting():
	world.get_node("CanvasLayer").get_child(0).queue_free() # remove gui
	own_player.disabled_movement = false # enable player movement
	own_player.get_node("CanvasLayer/playerGUI").setVisibility("self", 1) #add player gui
	current_votes.clear()

func set_chosen(id): # called form signal chosen comming from player meeting box (button)
	world.get_node("CanvasLayer").get_child(0).chosen = id # set chosen (var in gui script) to chosen palyer id
	request_vote(id)

func request_vote(id: int):
	pass

func add_vote(voter_id, voted_id):
	validate_vote(voter_id, voted_id)
	var color =  Color(colors[player_characters[voter_id].color]) # set vote color to voter color
	var gui = world.get_node("CanvasLayer").get_child(0)
	
	if voted_id >= 0: # if its player box then get their box and add vote to it
		var box = gui.get_player_box(voted_id)
		box.set_vote(color) 
	elif voted_id == -1: # if its skip button then add vote there
		gui.get_node("S").set_vote(color)
	
	# set little marker next to voter box indicating that they voted
	var voter_box = gui.get_player_box(voter_id)
	voter_box.set_voted()
	
	
	# if all players voted stop voting
	if current_votes.size() == player_characters.size() - get_tree().get_nodes_in_group("rip").size():
		gui.progress_meeting()

func validate_vote(voter_id, voted_id):
	if !current_votes.has(voter_id):
		current_votes[voter_id] = voted_id
		
	for id in current_votes.keys():
		if !player_characters.has(id):
			current_votes.erase(id)

func recalculate_pos():
	var radius:float = 750.0
	var elipsyfy:float = 1.8
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

func get_spawn_position(id: int) -> Vector2:
	if world:
		if gamestate==LOBBY:
			return world.get_node("lobby-position").global_position
		else:
			return world.get_node("Mapa/YSort/meeting-table/spawnpositions/%s" % id).global_position
	return Vector2(0, 0)

func game_start(params, taskstuff):
	own_player.get_node("KillCooldown").wait_time = gamesettings["kill-cooldown"]
	var Task := load("res://scripts/tasks/Task.cs")
	recalculate_pos()
	for i in params["imp"]:
		if player_characters.has(i):
			#make impostor
			pass
	if "impostor" == "impostor": #scale sight range if player is impostor
		own_player.sight_range_scale = gamesettings["impostor-vision"]
	else:
		own_player.sight_range_scale = gamesettings["crewmate-vision"]
	own_player.sight_range = own_player.default_sight_range * own_player.sight_range_scale
	for t in taskstuff:
		var task = Task.GetTaskByID(t)
		task.local=true
		own_player.localTaskList.append(task)
	for c in player_characters:
		player_characters[c].global_position = get_spawn_position(c)
	own_player.get_node("CanvasLayer/playerGUI").updateGUI()
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
