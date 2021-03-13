extends Matchmaking_Connection

class_name Server_Matchmaking

signal client_connecting(conf)
signal client_left(id)
signal received_session(id, sess)
signal received_candidate(id, cand)
signal key_changed(key)

var clientsettings

func _init(url, settings).(url):
	clientsettings = settings

func _ready():
# warning-ignore:return_value_discarded
	self.connect("matchmaking_received_message", self, "parse_matchmaking")

func parse_signaling(msg:  String):
	if msg.begins_with("HELLO:"):
		var arr = msg.split(":", false, 1)
		if arr.size()==2:
			var pars=JSON.parse(arr[1])
			if pars.error==OK && pars.result is Dictionary:
				var conf=pars.result
				if conf.has("key"):
					emit_signal("join_room", conf)
					return
		wsc.disconnect_from_host(4000, "WRONG_HELLO")
	elif msg.begins_with("JOIN:"):
		var arr = msg.split(":", false, 1)
		if arr.size()<2: return
		var pars = JSON.parse(arr[1])
		if pars.error!=OK: return
		if pars.result is Dictionary:
			var conf: Dictionary = pars.result
			if !conf.has('id'):
				return
			conf.id=int(conf.id)
			print("id:", conf.id)
			if !conf.has('webrtc') or !conf.has('username'):
				kick(conf.id)
				return
			emit_signal("client_connecting", conf)
	elif msg.begins_with("CONNECTION:"):
		var arr = msg.split(":", false, 3)
		if arr.size()<4:
			return
		var id = int(arr[1])
		if arr[2]=="SESSION":
			emit_signal("received_session", id, arr[3])
		elif arr[2]=="CANDIDATE":
			emit_signal("received_candidate", id, arr[3])
		else:
			kick(id)
	elif msg.begins_with("KEY:"):
		var arr = msg.split(":", false, 1)
		if arr.size()<2: return
		emit_signal("key_changed", arr[1])
		return

func kick(id):
	send_message("LEAVE:"+str(id))
	emit_signal("client_left", id)

func server_hello(settings):
	send_message("CLIENT:"+JSON.print({"username": settings.username}))

func refresh_servers():
	send_message("LIST")

func send_candidate(cand: String):
	send_message("CONNECTION:CANDIDATE:"+cand)

func send_session(sess: String):
	send_message("CONNECTION:SESSION:"+sess)
