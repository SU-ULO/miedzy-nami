extends Node


class_name Game_Connection

var established: bool = false

var config: Dictionary

var peer = WebRTCPeerConnection.new()
var game_updates = peer.create_data_channel("updates", {"negotiated": true, "id":1, "maxRetransmits": 0})
var game_events = peer.create_data_channel("events", {"negotiated": true, "id":2})
var game_init = peer.create_data_channel("init", {"negotiated": true, "id":3})

signal send_session
signal send_candidate

signal fail
signal success

func _init(conf: Dictionary):
	config=conf

func _ready():
#	if peer.initialize(config["webrtc"])!=OK:
#		emit_signal("fail")
#		return
	peer.connect("ice_candidate_created", self, "_on_candidate")
	peer.connect("session_description_created", self, "_on_session")

func _on_session(type, sdp):
	if peer.set_local_description(type, sdp)!=OK:
		emit_signal("fail")
		return
	emit_signal("send_session", JSON.print({"type": type, "sdp": sdp}))

func _on_candidate(media, index, name):
	emit_signal("send_candidate", JSON.print({"media": media, "index": index, "name":name}))

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

func _process(_delta):
	peer.poll()
	if !established and peer.get_connection_state()==WebRTCPeerConnection.STATE_CONNECTED:
		established=true
		emit_signal("success")

func _exit_tree():
	peer.close()
