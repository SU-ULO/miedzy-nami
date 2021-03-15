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
	var preloaded_dummy = preload("res://entities/dummyplayer.tscn")
	own_id = id
	for c in data:
		var init_data = data[c]
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
