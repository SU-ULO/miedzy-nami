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
