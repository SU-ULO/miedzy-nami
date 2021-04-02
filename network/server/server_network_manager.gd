extends NetworkManager

class_name ServerNetworkManager

var connected_clients := Dictionary()

var debug:bool = true

signal kick(id)
signal send_session(id, sess)
signal send_candidate(id, cand)
signal gameinprogresschange(inprogress)

func _ready():
	var gs = Globals.read_file("user://gs.settings")
	if gs and gs is Dictionary:
		for k in gamesettings:
			if gs.has(k):
				gamesettings[k]=gs[k]

func is_username_taken(requested_name: String)->bool:
	if own_player.username==requested_name: return true
	for c in connected_clients.values():
		if c.config.username==requested_name:
			return true
	return false

func get_non_taken_username(requested_name: String) -> String:
	if !is_username_taken(requested_name):
		return requested_name
	var num=2
	while is_username_taken(requested_name+String(num)):
		num+=1
	return requested_name+String(num)

func create_client(config):
	if !connected_clients.has(config.id):
		config.username=get_non_taken_username(config.username)
		var client = JoinedClient.new(config)
		connected_clients[config.id] = client
		client.connect("send_session", self, "send_session", [config.id])
		client.connect("send_candidate", self, "send_candidate", [config.id])
		client.connect("success", self, "spawn_player", [config.id])
		client.connect("fail", self, "kick", [config.id])
		client.connect("meeting_requested", self, "handle_meeting_request", [config.id])
		client.connect("kill_requested", self, "handle_kill_request")
		client.connect("sabotage_requested", self, "handle_sabotage_request")
		client.connect("end_sabotage_requested", self, "handle_end_sabotage_request")
		client.connect("cameras_enable_requested", self, "handle_cameras_enable_request")
		client.connect("tasks_done", self, "handle_tasks_done", [config.id])
		client.connect("gui_sync_requested", self, "handle_gui_sync_request")
		client.connect("color_update", self, "handle_color_change_request", [config.id])
		client.connect("look_update", self, "handle_set_look", [config.id])
		client.connect("set_invisible", self, "handle_set_invisible")
		client.connect("vote", self, "handle_vote_request", [config.id])
		add_child(client)
	else:
		kick(config.id)

func set_session(id, sess):
	if connected_clients.has(id):
		connected_clients[id].set_session(sess)

func set_candidate(id, cand):
	if connected_clients.has(id):
		connected_clients[id].set_candidate(cand)

func send_session(sess: String, id: int):
	emit_signal("send_session", id, sess)

func send_candidate(cand: String, id: int):
	emit_signal("send_candidate", id, cand)

func create_world(config):
	.create_world(config)
	print(server_key)
	own_player = preload("res://entities/player.tscn").instance()
	own_player.username = get_parent().menu.usersettings["username"]
	player_characters[own_id]=own_player
	own_player.global_position = get_spawn_position(own_id)
	own_player.color = get_free_color_and_set()
	world.get_node('Mapa/YSort').add_child(own_player)
	emit_signal("joined_room")

func recreate_world():
	var init_dict := {}
	for ch in player_characters.values():
		init_dict[ch.owner_id]=ch.generate_init_data()
		init_dict[ch.owner_id]["pos"]=get_spawn_position(ch.owner_id)
		init_dict[ch.owner_id]["imp"]=false
		init_dict[ch.owner_id]["dead"]=false
	.recreate_world()
	taken_colors=0
	player_characters[0].set_init_data(init_dict[0])
	set_color_taken(own_player.color)
# warning-ignore:return_value_discarded
	init_dict.erase(0)
	own_player.get_node("sprites").loadLook()
	for c in init_dict:
		spawn_player(c, init_dict[c])
	sync_colors()

func spawn_player(id: int, init_data: Dictionary = {}):
	if !connected_clients.has(id): return
	var new_character = preload("res://entities/dummyplayer.tscn").instance()
	new_character.owner_id = id
	if init_data.empty():
		new_character.username = connected_clients[id].config.username
		new_character.global_position = get_spawn_position(id)
		new_character.color = get_free_color_and_set()
	else:
		new_character.set_init_data(init_data)
		set_color_taken(new_character.color)
	player_characters[id]=new_character
	connected_clients[id].connect("player_character_sync", new_character, "set_sync_data")
	world.get_node('Mapa/YSort').add_child(new_character)
	var joining_player_init_data = new_character.generate_init_data()
	for cid in connected_clients:
		var c = connected_clients[cid]
		if cid==id:
			var all_players_init_data := Dictionary()
			for ch in player_characters.values():
				all_players_init_data[ch.owner_id]=ch.generate_init_data()
			var all_init_data = {
				"players": all_players_init_data,
				"gamestate": [gamestate, gamestate_params],
				"gamesettings": gamesettings
				}
			c.send_initial_sync(all_init_data, id)
		elif c.joined:
			c.send_spawning_player_sync(joining_player_init_data, id)
	connected_clients[id].joined=true
	sync_colors()

func kick(id):
	if connected_clients.has(id):
		var c = connected_clients[id]
# warning-ignore:return_value_discarded
		connected_clients.erase(id)
		if c.joined:
			for cc in connected_clients.values():
				if cc.joined:
					cc.send_player_removal_notification(id)
		c.queue_free()
	if player_characters.has(id):
		unset_color_taken(player_characters[id].color)
		player_characters[id].queue_free()
# warning-ignore:return_value_discarded
		player_characters.erase(id)
	emit_signal("kick", id)

func check_winning_conditions():
	if gamestate==STARTED:
		var alivelivecrewmates := 0
		var aliveimpostors := 0
		var tasksdone:=true
		for c in player_characters.values():
			if c.is_in_group("impostors"):
				if !c.dead:
					aliveimpostors+=1
			else:
				if !c.donealltasks:
					tasksdone=false
				if !c.dead:
					alivelivecrewmates+=1
		if aliveimpostors==0 or tasksdone:
			gamestate=ENDED
			gamestate_params=true
			sync_gamestate()
			end_game(gamestate_params)
		elif aliveimpostors>=alivelivecrewmates:
			gamestate=ENDED
			gamestate_params=false
			sync_gamestate()
			end_game(gamestate_params)

func _process(_delta):
	var sync_data := Dictionary()
	for pc in player_characters.values():
		sync_data[pc.owner_id]=pc.generate_sync_data()
	for c in connected_clients.values():
		if c.joined:
			c.send_player_character_sync_data(sync_data)

func kill(dead: int, pos: Vector2, spawnbody: bool=true):
	.kill(dead, pos, spawnbody)
	check_winning_conditions()

func request_meeting(dead: int):
	handle_meeting_request(dead, own_id)

func handle_meeting_request(dead: int, caller: int):
	if gamestate==MEETING: return
	gamestate=MEETING
	gamestate_params={"caller": caller, "dead": dead}
	for c in connected_clients.values():
		c.send_gamestate(gamestate, gamestate_params)
	start_meeting(caller, dead)

func request_kill(dead: int):
	handle_kill_request(dead)

func handle_kill_request(dead: int):
	if !(player_characters.has(dead)): return
	var pos: Vector2 = player_characters[dead].position
	for c in connected_clients.values():
		c.send_kill(dead, pos)
	kill(dead, pos)

func sync_gamestate(opt=Dictionary()):
	emit_signal("gameinprogresschange", gamestate!=LOBBY)
	for c in connected_clients:
		if connected_clients.has(c):
			var cl = connected_clients[c]
			if cl.joined:
				cl.send_gamestate(gamestate, gamestate_params, opt[c] if opt.has(c) else null)

func pick_impostors()->Array:
	var ids = player_characters.keys()
	var impostors:=[]
	while impostors.size()<gamesettings["impostor-count"]:
		var rnd = ids[randi()%ids.size()]
		if !impostors.has(rnd):
			impostors.push_back(rnd)
	return impostors

func request_game_start():
	if !debug:
		if player_characters.size()<2*gamesettings["impostor-count"]+1: return
	var Task := load("res://scripts/tasks/Task.cs")
	gamestate = STARTED
	gamestate_params = {"imp": pick_impostors()}
	Task.SetTaskCategoriesPerPlayer(3, gamesettings["short-tasks"])
	Task.SetTaskCategoriesPerPlayer(0, gamesettings["long-tasks"])
	var ids = player_characters.keys()
	ids.sort()
	Task.DivideTasks(ids)
	var opt = Dictionary()
	for c in player_characters:
		opt[c]=Task.GetTaskIDsForPlayerID(c)
	sync_gamestate(opt)
	game_start(gamestate_params, Task.GetTaskIDsForPlayerID(own_id))

func request_sabotage(type: int):
	handle_sabotage_request(type, own_id)
	
func request_end_sabotage(type: int):
	handle_end_sabotage_request(type)

func handle_end_sabotage_request(type: int):
	for c in connected_clients.values():
		c.send_end_sabotage(type)
	emit_signal("sabotage_end", type)

func handle_sabotage_request(type: int, _player_id: int):
	# TODO: check if the requester (player_id) is an impostor
	
	# we check if the timer is up on the server side too to prevent potential client/server desyncs
	if own_player.is_sabotage_timer_done():
		for c in connected_clients.values():
			c.send_sabotage_start(type)
			
		emit_signal("sabotage", type)
	
func request_cameras_enable(on_off: bool):
	handle_cameras_enable_request(on_off)

func handle_cameras_enable_request(on_off: bool):
	for c in connected_clients.values():
		c.send_cameras_enable(on_off)
	cameras_enable(on_off)

func handle_tasks_done(id):
	if player_characters.has(id):
		player_characters[id].donealltasks=true
	check_winning_conditions()

func request_inform_all_tasks_finished():
	handle_tasks_done(own_id)

func request_gui_sync(gui_name: String, gui_data):
	handle_gui_sync_request(gui_name, gui_data)
	
func handle_gui_sync_request(gui_name: String, gui_data):
	for c in connected_clients.values():
		c.send_gui_sync(gui_name, gui_data)
	emit_signal("gui_sync", gui_name, gui_data)

func handle_game_settings(settings):
	Globals.save_file("user://gs.settings", settings)
	.handle_game_settings(settings)

func set_game_settings(settings):
	for c in connected_clients.values():
		c.send_game_settings(settings)
	handle_game_settings(settings)

func request_color_change(c: int):
	handle_color_change_request(c, own_id)

func sync_colors():
	var p = Dictionary()
	for c in player_characters:
		p[c]=player_characters[c].color
	for c in connected_clients.values():
		if c.joined:
			c.send_colors(taken_colors, p)
	handle_colors_change(taken_colors, p)

func handle_color_change_request(c: int, id: int):
	if !is_color_taken(c):
		unset_color_taken(player_characters[id].color)
		player_characters[id].color = c
		set_color_taken(c)
	sync_colors()

func request_set_look(look: Dictionary):
	handle_set_look(look, own_id)

func handle_set_look(look: Dictionary, id: int):
	for c in connected_clients.values():
		if c.joined:
			c.send_look(id, look)
	set_look(id, look)

func request_set_invisible(id, val: bool):
	handle_set_invisible(id, val)

func handle_set_invisible(id, val: bool):
	for c in connected_clients.values():
		c.send_set_invisible(id, val)
	set_invisible(id, val)

func request_vote(id: int):
	handle_vote_request(id, own_id)

func handle_vote_request(voted, voter):
	for c in connected_clients.values():
		c.send_vote(voter, voted)
	add_vote(voter, voted)

func set_meeting_state(state):
	if state==4:
		gamestate=STARTED
		gamestate_params=null
		sync_gamestate()
		end_meeting()
		request_kill(votingwinnerid)
	else: .set_meeting_state(state)

func request_end_game():
	gamestate=LOBBY
	gamestate_params=null
	sync_gamestate()
	for c in connected_clients.values():
		c.joined=false
	recreate_world()

func end_game(crew_win: bool):
	.end_game(crew_win)
	yield(get_tree().create_timer(1.0), "timeout")
	request_end_game()
