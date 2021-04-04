extends NetworkManager

class_name ClientNetworkManager

var joined_server = null

signal send_session(sess)
signal send_candidate(cand)

func create_world(config):
	.create_world(config)
	joined_server = JoinedServer.new(config)
	joined_server.connect("send_session", self, "send_session")
	joined_server.connect("send_candidate", self, "send_candidate")
	joined_server.connect("initial_sync", self, "handle_initial_sync")
	joined_server.connect("remote_player_joined", self, "handle_remote_player_joining")
	joined_server.connect("remote_player_left", self, "handle_remote_player_leaving")
	joined_server.connect("players_sync", self, "handle_players_sync")
	joined_server.connect("kill", self, "kill")
	joined_server.connect("state_sync", self, "handle_state_sync")
	joined_server.connect("sabotage", self, "handle_sabotage")
	joined_server.connect("end_sabotage", self, "handle_end_sabotage")
	joined_server.connect("cameras_enable", self, "cameras_enable")
	joined_server.connect("gui_sync", self, "handle_gui_sync")
	joined_server.connect("game_settings", self, "handle_game_settings")
	joined_server.connect("colors_sync", self, "handle_colors_change")
	joined_server.connect("look", self, "set_look")
	joined_server.connect("invisible", self, "set_invisible")
	joined_server.connect("vote", self, "add_vote")
	joined_server.connect("vc_offer", Globals.start.vc, "set_offer")
	joined_server.connect("vc_answer", Globals.start.vc, "set_answer")
	joined_server.connect("vc_candidate", Globals.start.vc, "set_candidate")
	add_child(joined_server)

func recreate_world(): #that is a copy from NetworkManager but we use NetworkManager's create_world
	taken_colors=0
	remove_child(world)
	world.queue_free()
	player_characters.clear()
	own_player=null
	.create_world(currentconfig)

func send_session(sess):
	emit_signal("send_session", sess)
	
func send_candidate(cand):
	emit_signal("send_candidate", cand)

func set_session(sess: String):
	if joined_server:
		joined_server.set_session(sess)

func set_candidate(cand: String):
	if joined_server:
		joined_server.set_candidate(cand)

func handle_initial_sync(id: int, data: Dictionary):
	var players_data = data["players"]
	gamestate=data["gamestate"][0]
	gamestate_params=data["gamestate"][1]
	var preloaded_dummy = preload("res://entities/dummyplayer.tscn")
	own_id = id
	Globals.start.vc.own_id=own_id
	for c in players_data:
		var init_data = players_data[c]
		var added_player
		if c==own_id:
			added_player = preload("res://entities/player.tscn").instance()
			own_player = added_player
		else:
			Globals.start.vc.addpeer(c)
			added_player = preloaded_dummy.instance()
		added_player.owner_id = c
		player_characters[c]=added_player
		added_player.set_init_data(init_data)
		world.get_node('Mapa/YSort').add_child(added_player)
		added_player.get_node("sprites").loadLook()
	handle_game_settings(data["gamesettings"])
	emit_signal("joined_room")
	if endscreen: endscreen.queue_free()

func handle_remote_player_joining(id: int, data: Dictionary):
	Globals.start.vc.addpeer(id)
	var added_player := preload("res://entities/dummyplayer.tscn").instance()
	added_player.set_init_data(data)
	player_characters[id] = added_player
	world.get_node('Mapa/YSort').add_child(added_player)

func handle_remote_player_leaving(id: int):
	Globals.start.vc.removepeer(id)
	if player_characters.has(id):
		var c = player_characters[id]
# warning-ignore:return_value_discarded
		player_characters.erase(id)
		c.queue_free()

func handle_players_sync(data):
	for c in data:
		if c!=own_id and player_characters.has(c):
			player_characters[c].set_sync_data(data[c])

func _process(_delta):
	if joined_server and joined_server.established and own_player:
		joined_server.send_player_character_sync(own_player.generate_sync_data())

func request_meeting(dead: int):
	if joined_server:
		joined_server.send_meeting_request(dead)

func request_kill(dead: int):
	if joined_server:
		joined_server.send_kill_request(dead)

func request_sabotage(type: int):
	if joined_server and own_player:
		joined_server.send_sabotage_request(type, own_id)

func request_end_sabotage(type: int):
	if joined_server and own_player:
		joined_server.send_end_sabotage_request(type)

func handle_state_sync(state, params, opt=null):
	if gamestate==MEETING and state==STARTED:
		gamestate = state
		gamestate_params = params
		end_meeting()
		return
	gamestate = state
	gamestate_params = params
	if state==STARTED:
		game_start(gamestate_params, opt)
	elif state==MEETING:
		start_meeting(gamestate_params["caller"], gamestate_params["dead"])
	elif state==ENDED:
		end_game(gamestate_params)
	elif state==LOBBY:
		recreate_world()

func game_start(params, taskstuff):
	.game_start(params, taskstuff)
	sentalldone=false

func handle_sabotage(type):
	if joined_server and own_player:
		emit_signal("sabotage", type)
		
func handle_end_sabotage(type):
	if joined_server and own_player:
		emit_signal("sabotage_end", type)

func request_cameras_enable(on_off: bool):
	if joined_server:
		joined_server.send_cameras_enable_request(on_off)

func request_gui_sync(gui_name: String, gui_data):
	if joined_server:
		joined_server.send_gui_sync_request(gui_name, gui_data)
		
func handle_gui_sync(gui_name: String, gui_data):
	emit_signal("gui_sync", gui_name, gui_data)

func request_color_change(color: int):
	if joined_server:
		joined_server.send_color_change(color)

func request_set_look(look: Dictionary):
	if joined_server:
		joined_server.send_look_update(look)
func request_set_invisible(id, val: bool):
	if joined_server:
		joined_server.send_set_invisible(id, val)

func request_vote(id: int):
	if joined_server:
		joined_server.send_vote(id)

func request_inform_all_tasks_finished():
	joined_server.send_tasks_done()

func send_vc_offer(offer, id: int):
	if joined_server:
		joined_server.send_vc_offer(offer, id)

func send_vc_answer(answer, id):
	if joined_server:
		joined_server.send_vc_answer(answer, id)

func send_vc_candidate(candidate, id):
	if joined_server:
		joined_server.send_vc_candidate(candidate, id)

