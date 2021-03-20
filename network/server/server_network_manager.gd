extends NetworkManager

class_name ServerNetworkManager

var connected_clients := Dictionary()

signal kick(id)
signal send_session(id, sess)
signal send_candidate(id, cand)

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
	own_player = preload("res://entities/player.tscn").instance()
	own_player.username = get_parent().menu.usersettings["username"]
	player_characters[own_id]=own_player
	world.get_node('Mapa/YSort').add_child(own_player)
	emit_signal("joined_room")

func spawn_player(id: int):
	if !connected_clients.has(id): return
	var new_character = preload("res://entities/dummyplayer.tscn").instance()
	new_character.owner_id = id
	new_character.username = connected_clients[id].config.username
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
			c.send_initial_sync(all_players_init_data, id)
		elif c.joined:
			c.send_spawning_player_sync(joining_player_init_data, id)
	connected_clients[id].joined=true

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
		player_characters[id].queue_free()
# warning-ignore:return_value_discarded
		player_characters.erase(id)
	emit_signal("kick", id)

func _process(_delta):
	var sync_data := Dictionary()
	for pc in player_characters.values():
		sync_data[pc.owner_id]=pc.generate_sync_data()
	for c in connected_clients.values():
		if c.joined:
			c.send_player_character_sync_data(sync_data)

func request_meeting(dead: int):
	handle_meeting_request(dead, own_id)

func handle_meeting_request(dead: int, caller: int):
	#here we should check if meeting is in progress and return in case it is
	for c in connected_clients.values():
		c.send_meeting_start(caller, dead)
	start_meeting(caller, dead)

func request_kill(dead: int):
	handle_kill_request(dead)

func handle_kill_request(dead: int):
	if !(player_characters.has(dead)): return
	var pos: Vector2 = player_characters[dead].position
	for c in connected_clients.values():
		c.send_kill(dead, pos)
	kill(dead, pos)
