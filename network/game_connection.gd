extends Node


class_name Game_Connection

var established: bool = false

var config: Dictionary

var peer = WebRTCPeerConnection.new()

var game_updates: WebRTCDataChannel
var game_events: WebRTCDataChannel

signal send_session
signal send_candidate

signal fail
signal success
# warning-ignore:unused_signal
signal join

func _init(conf: Dictionary):
	config=conf

func _ready():
	if peer.initialize(config["webrtc"])!=OK:
		emit_signal("fail")
		return
	
	game_updates = peer.create_data_channel("updates",
		{"negotiated": true, "id":1, "maxRetransmits": 0})
	game_events = peer.create_data_channel("events",
		{"negotiated": true, "id":2})
	if game_updates==null || game_events==null:
		emit_signal("fail")
		return
	
	peer.connect("ice_candidate_created", self, "_on_candidate")
	peer.connect("session_description_created", self, "_on_session")

func _on_session(type, sdp):
	if peer.set_local_description(type, sdp)!=OK:
		emit_signal("fail")
		return
	emit_signal("send_session", JSON.print({"type": type, "sdp": sdp}))

func _on_candidate(media, index, sdp_name):
	emit_signal("send_candidate", JSON.print({"media": media, "index": index, "name": sdp_name}))

func set_session(sess: String):
	var pars = JSON.parse(sess)
	if pars.error==OK and pars.result is Dictionary:
		var session = pars.result
		if session.has("type") and session.has("sdp"):
			if peer.set_remote_description(session.type, session.sdp)==OK:
				return
	emit_signal("fail")

func set_candidate(cand: String):
	var pars = JSON.parse(cand)
	if pars.error==OK and pars.result is Dictionary:
		var session = pars.result
		if session.has("media") and session.has("index") and session.has("name"):
			if peer.add_ice_candidate(session.media, session.index, session.name)==OK:
				return
	emit_signal("fail")

func leave():
	pass

func send_updates(input):
	return game_updates.put_var(input)

func send_events(input):
	return game_events.put_var(input)

func handle_updates(_input):
	pass

func handle_events(_input):
	pass

func _process(_delta):
	peer.poll()
	if !established and peer.get_connection_state()==WebRTCPeerConnection.STATE_CONNECTED:
		established=true
		emit_signal("success")
	elif established:
		if peer.get_connection_state()!=WebRTCPeerConnection.STATE_CONNECTED:
			established=false
			emit_signal("fail")
		else:
			if game_events.get_ready_state()==WebRTCDataChannel.STATE_OPEN:
				while game_events.get_available_packet_count()>0:
					handle_events(game_events.get_var())
			if game_updates.get_ready_state()==WebRTCDataChannel.STATE_OPEN:
				while game_updates.get_available_packet_count()>0:
					handle_updates(game_updates.get_var())

func _exit_tree():
	peer.close()
