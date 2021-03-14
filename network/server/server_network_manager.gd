extends NetworkManager

class_name ServerNetworkManager

var connected_clients := Dictionary()

signal kick(id)
signal send_session(id, sess)
signal send_candidate(id, cand)

func is_username_taken(requested_name: String)->bool:
	for c in connected_clients.values():
		if c.conf.username==requested_name:
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
	world.get_node('Mapa/YSort').add_child(own_player)
	emit_signal("joined_room")

func spawn_player(id: int):
	print("spawning id: "+String(id))

func kick(id):
	if connected_clients.has(id):
		connected_clients[id].queue_free()
# warning-ignore:return_value_discarded
		connected_clients.erase(id)
	emit_signal("kick", id)
