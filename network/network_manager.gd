extends Node

class_name NetworkManager

enum {LOBBY, STARTED, MEETING, ENDED}
var gamestate := LOBBY
var gamestate_params = null

var currentconfig

const preloadedmap := preload('res://scenes/school.tscn')

var world = null
var player_characters := Dictionary()
var own_player = null
var own_id := 0
var server_key := ""

var gamesettings := {
	"impostor-count": 1,
	"voice-chat": 0,
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
var comms_disabled:bool = 0

var meeting_gui = null
var current_votes = {}

# warning-ignore:unused_signal
signal joined_room()
# warning-ignore:unused_signal
signal left_room()

signal meeting_start()

# warning-ignore:unused_signal
signal gui_sync(gui_name, gui_data)

signal color_taken()

# warning-ignore:unused_signal
signal sabotage(type)

# warning-ignore:unused_signal
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

func cleanup_tasks():
	Task.ClientCleanup()

func create_world(config):
	currentconfig=config
	server_key = config.key
	cleanup_tasks()
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
		if endscreen: endscreen.queue_free()

func recreate_world():
	taken_colors=0
	remove_child(world)
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
	
	#end sabotage
	if own_player.currentSabotage == 4:
		own_player.handle_end_sabotage(4)
	
	#end all interactions
	if own_player.currentInteraction != null:
		own_player.currentInteraction.EndInteraction(own_player)
		own_player.currentInteraction = null
	
	#close all gui
	if own_player.get_node("GUI").currentGUI != null:
		own_player.replace_on_canvas()
	
	#get rid of all the bodies
	for i in world.get_tree().get_nodes_in_group("deadbody"):
		i.queue_free()
	
	#disable movement and calculate teleport positions
	own_player.disabled_movement = true
	recalculate_pos()
	
	own_player.position = get_spawn_position(own_id)
	var gui = load("res://gui/meeting/meetingGUI.tscn").instance()
	gui.show_imps = gamesettings["comfirm-ejects"]
	var playerbox = load("res://gui/meeting/PlayerMeetingBox.tscn")
	meeting_gui = gui
	
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
			gui.get_node("BG/H/V" + String(iter%2 + 1)).add_child(box)
			
			iter += 1
	
	for rip in rips: # now same for rips because we want them last on list
		var box = playerbox.instance()

		box.connect("chosen", self, "set_chosen")
		box.id = rip
		box.color =  Color(colors[player_characters[rip].color])
		box.get_node("Button/L").text = player_characters[rip].username
		
		gui.get_node("BG/H/V" + String(iter%2 + 1)).add_child(box)
		# aslo different color cause they dead
		box.get_node("Button").get_stylebox("disabled", "").bg_color = Color("#2874A6")
		iter += 1
	
	#now we disable all butons because no one can vote in discussion time
	gui.time = gamesettings["discussion-time"]
	gui.set_all_buttons(0)
	var skip = gui.get_node("BG/S")
	
	#connect "click" signal to skip button and signal to change meeting state to voting time
	skip.connect("chosen", self, "set_chosen")
	gui.connect("meeting_state_changed", self, "set_meeting_state")
	
	# show gui on screen
	own_player.get_node("GUI").add_to_canvas(gui, false)
	
	emit_signal("meeting_start")
	apply_vc_settings()

var votingwinnerid := -1

func set_meeting_state(state): # func to toggle from discussion time to voting time and to reveal results
	var gui = meeting_gui #get gui
	if meeting_gui == null: return null
	
	gui.meeting_state += 1
	
	if state == 1: # voting starts
		if own_player.is_in_group("rip") == false: # if player is dead then wi dont need to do anything
			for player in player_characters.keys(): # otherwise for every alive player we anable their button
				if player_characters[player].is_in_group("rip") == false:
					gui.get_player_box(player).get_node("Button").disabled = false
			gui.get_node("BG/S").disabled = false # also skip button
		
		#set time and label
		gui.time = gamesettings["voting-time"]
		gui.label_text = "Koniec głosowania za: "
	elif state == 2: # voting ended
		#show votes
		for box in gui.get_node("BG/H/V1").get_children():
			box.set_vote_visibility(1)
			
		for box in gui.get_node("BG/H/V2").get_children():
			box.set_vote_visibility(1)
		
		gui.get_node("BG/S/SH").visible = true
		
		#determin meeting "winner"
		
		var votes = {}
		# count votes
		for vote in current_votes.keys():
			if votes.has(current_votes[vote]):
				votes[current_votes[vote]] += 1
			else:
				votes[current_votes[vote]] = 1
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
		
		votingwinnerid = best_id
		
		# show votes
		if player_characters.has(best_id):
			if player_characters[best_id].is_in_group("impostors"):
				imps -= 1
			gui.update_verdict(player_characters[best_id], imps)
		else:
			gui.update_verdict(null, imps)
	elif state == 3: # show verdict
		gui.show_verdict()
		kill(votingwinnerid, Vector2(0, 0), false)

func end_meeting():
	# remove gui
	own_player.get_node("GUI").clear_canvas()
	meeting_gui = null 
	
	#hide chat if open
	own_player.get_node("GUI/CloseButton/ChatPanel").show(false)
	own_player.get_node("GUI/CloseButton/ChatPanel/bg").visible = false
	
	own_player.disabled_movement = false # enable player movement
	current_votes.clear() # clear votes
	if own_player.is_in_group("impostors"): # set cooldown for impostor
		own_player.get_node("KillCooldown").start(gamesettings["kill-cooldown"] / 3)
	apply_vc_settings()

func set_chosen(id): # called form signal chosen comming from player meeting box (button)
	if meeting_gui == null: return false
	meeting_gui.chosen = id # set chosen (var in gui script) to chosen palyer id
	request_vote(id)

func request_vote(_id: int):
	pass

func add_vote(voter_id, voted_id):
	validate_vote(voter_id, voted_id)
	var color
	if gamesettings["anonnymous-votes"]:
		color = Color("#666666")
	else:
		color =  Color(colors[player_characters[voter_id].color]) # set vote color to voter color
	
	var gui = meeting_gui
	if meeting_gui == null: return false
	
	if voted_id >= 0: # if player was voted, get their player box and add vote to it
		var box = gui.get_player_box(voted_id)
		box.set_vote(color) 
	elif voted_id == -1: # if vote skipped, add vote to skip button
		gui.get_node("BG/S").set_vote(color)
	
	# set little marker next to voter box indicating that they voted
	var voter_box = gui.get_player_box(voter_id)
	voter_box.set_voted()
	
	# if all players voted stop voting
	if current_votes.size() == player_characters.size() - get_tree().get_nodes_in_group("rip").size():
		gui.progress_meeting()

func validate_vote(voter_id, voted_id):
	if player_characters.has(voted_id) or voted_id == -1:
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

func kill(dead: int, pos: Vector2, spawnbody: bool=true, killer: int = -1):
	if player_characters.has(dead):
		var killed = player_characters[dead]
		if spawnbody:
			killed.turn_into_corpse(pos, killer)
		else:
			killed.dead = true
			killed.add_to_group("rip")
			killed.visible = false
		if own_player.dead:
			for c in player_characters.values():
				c.visible = true
				if c.owner_id==own_id:
					c.modulate = Color(1, 1, 1, 0.8)
					own_player.collision_layer = 0
					own_player.collision_mask = 0b10000000000000000000
					own_player.sight_range = 200000000
					own_player.get_node("Light").shadow_enabled = false
				elif c.dead:
					c.modulate = Color(1, 1, 1, 0.2)

func get_spawn_position(id: int) -> Vector2:
	if world:
		if gamestate==LOBBY:
			return world.get_node("lobby-position").global_position
		else:
			return world.get_node("Mapa/YSort/meeting-table/spawnpositions/%s" % id).global_position
	return Vector2(0, 0)

func game_start(params, taskstuff):
	for i in world.get_tree().get_nodes_in_group("tasks"):
		if i.material != null:
			if i.material is ShaderMaterial:
				i.material.set_shader_param("aura_width", 0)
	own_player.get_node("KillCooldown").wait_time = gamesettings["kill-cooldown"]
	recalculate_pos()
	for i in params["imp"]:
		if player_characters.has(i):
			player_characters[i].become_impostor()
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
	own_player.get_node("GUI/PlayerCanvas/playerGUI").updateTaskList()
	if own_player.is_in_group("impostors"):
		own_player.get_node("KillCooldown").start(gamesettings["kill-cooldown"] / 3)
	own_player.get_node("KillArea").scale = \
		Vector2((gamesettings["kill-distance"] + 1)/2,(gamesettings["kill-distance"]+1)/2)
	apply_vc_settings()

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

func apply_vc_settings():
	var vcs = gamesettings["voice-chat"]
	if vcs==0:
		VoiceChat.setwantstospeak(false)
		VoiceChat.forcemute(true)
	else:
		VoiceChat.askforstream()
	if vcs==1:
		if gamestate==LOBBY or gamestate==MEETING:
			VoiceChat.forcemute(false)
		else:
			VoiceChat.forcemute(true)
	else:
		VoiceChat.forcemute(false)
	VoiceChat.setunmutepeers(calculate_muted_remotes())

func apply_settings_to_player():
	if own_player:
		own_player.player_speed = own_player.default_speed * gamesettings["player-speed"]
	apply_vc_settings()

func request_color_change(_color: int):
	pass

func handle_colors_change(taken: int, players: Dictionary):
	taken_colors=taken
	for p in players:
		if player_characters.has(p):
			player_characters[p].color = players[p]
			player_characters[p].get_node("sprites").loadLook()
	emit_signal("color_taken")

func request_set_look(_look: Dictionary):
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

var endscreen = null
func end_game(crew_win: bool):
	var end_screen = load("res://gui/meeting/verdict.tscn").instance()
	
	if crew_win:
		end_screen.get_node("Control/message").text = "Uczniowe wygrali!"
	else:
		end_screen.get_node("Control/message").text = "<nazwa impostorów> wygrali!"
		
	end_screen.get_node("Control/imps").text = "" # unused label
	end_screen.get_node("Control").visible = true
	self.add_child(end_screen)
	endscreen=end_screen
	if own_player.currentSabotage != 0:
		own_player.handle_end_sabotage(own_player.currentSabotage)
	apply_vc_settings()

func request_inform_all_tasks_finished():
	pass

var sentalldone:=false
func _process(_delta):
	if own_player:
		if Task.CheckAndClearAnyDirty():
			var state_changes : Dictionary = {}
			var started_changes: Dictionary = {}
			for t in Task.GetAllTasks():
				if t.dirty:
					t.dirty = false
					state_changes[t.taskID] = t.state
					started_changes[t.taskID] = t.started
					if t.started and t.state < t.maxState:
						own_player.localTaskList.append(t)
			tasks_update(state_changes, started_changes, own_id)
	if gamestate==STARTED:
		var alldone = true
		for t in Task.GetAllTasks():
			if t.local and !t.IsDone():
				alldone=false
				break
		if alldone and !sentalldone:
			request_inform_all_tasks_finished()

func tasks_update(state, started, _id):
	var tasks = Task.GetAllTasks()
	for i in state:
		if tasks[i].IsDone() == false:
			tasks[i].state = state[i]
		tasks[i].local = true
	for i in started:
		tasks[i].started = started[i]
		tasks[i].local = true

func send_vc_offer(_offer, _id: int):
	pass

func send_vc_answer(_answer, _id: int):
	pass

func send_vc_candidate(_candidate, _id: int):
	pass

func send_vc_speaking(_speaking: bool):
	pass

func _ready():
	VoiceChat.connect("offer", self, "send_vc_offer")
	VoiceChat.connect("answer", self, "send_vc_answer")
	VoiceChat.connect("candidate", self, "send_vc_candidate")
	VoiceChat.connect("speaking", self, "send_vc_speaking")
	VoiceChat.update_vc_mode()

func calculate_muted_remotes()->int:
	if !own_player: return 0
	var vcs = gamesettings["voice-chat"]
	if (((gamestate==LOBBY and vcs!=3) or gamestate==MEETING) and (vcs!=0)) or \
	(gamestate==STARTED and vcs==2):
		var out:=0
		for i in player_characters:
			if own_player.dead or !player_characters[i].dead:
				out|=1<<i
		return out
	elif gamestate==STARTED or gamestate==LOBBY and vcs == 3:
		var out := 0
		for p in own_player.players_in_voice_range():
			if own_player.dead or !p.dead:
				out|=1<<p.owner_id
		return out
	return 0
