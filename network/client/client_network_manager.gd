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
	joined_server.connect("meeting_start", self, "start_meeting")
	joined_server.connect("kill", self, "kill")
	joined_server.connect("state_sync", self, "handle_state_sync")
	joined_server.connect("sabotage", self, "handle_sabotage")
	joined_server.connect("end_sabotage", self, "handle_end_sabotage")
	joined_server.connect("cameras_enable", self, "cameras_enable")
	joined_server.connect("game_settings", self, "handle_game_settings")
	joined_server.connect("colors_sync", self, "handle_colors_change")
	add_child(joined_server)

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
	for c in players_data:
		var init_data = players_data[c]
		var added_player
		if c==own_id:
			added_player = preload("res://entities/player.tscn").instance()
			own_player = added_player
		else:
			added_player = preloaded_dummy.instance()
		added_player.owner_id=c
		player_characters[c]=added_player
		added_player.set_init_data(init_data)
		world.get_node('Mapa/YSort').add_child(added_player)
	handle_game_settings(data["gamesettings"])
	emit_signal("joined_room")

func handle_remote_player_joining(id: int, data: Dictionary):
	var added_player := preload("res://entities/dummyplayer.tscn").instance()
	added_player.set_init_data(data)
	player_characters[id] = added_player
	world.get_node('Mapa/YSort').add_child(added_player)

func handle_remote_player_leaving(id: int):
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
		if Task.CheckAndClearAnyDirty():
			var state_changes : Dictionary = {}
			var started_changes: Dictionary = {}
			for t in Task.GetAllTasks():
				if t.dirty:
					t.dirty = false
					state_changes[t.taskID] = t.state
					started_changes[t.taskID] = t.started
					if t.started and t.state < t.maxState:
						own_player.localTaskList.add(t)
			joined_server.send_tasks_update(state_changes, started_changes)

func request_meeting(dead: int):
	if joined_server:
		joined_server.send_meeting_request(dead)

func request_kill(dead: int):
	if joined_server:
		joined_server.send_kill_request(dead)

func request_sabotage(type: int):
	if joined_server and own_player:
		joined_server.send_sabotage_request(type, own_id)

func handle_state_sync(state, params, opt=null):
	gamestate = state
	gamestate_params = params
	if state==STARTED:
		game_start(gamestate_params, opt)

func handle_sabotage(type):
	if joined_server and own_player:
		own_player.handle_sabotage(type)
		
func handle_end_sabotage(type):
	if joined_server and own_player:
		own_player.handle_end_sabotage(type)

func request_cameras_enable(on_off: bool):
	if joined_server:
		joined_server.send_cameras_enable_request(on_off)

func request_color_change(color: int):
	if joined_server:
		joined_server.send_color_change(color)
