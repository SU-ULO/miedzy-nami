extends Matchmaking_Connection

class_name Server_Matchmaking

signal client_connecting(conf)
# warning-ignore:unused_signal
signal client_left(id)
signal received_session(id, sess)
signal received_candidate(id, cand)

var serversettings

func _init(url, settings).(url):
	serversettings = settings

func _ready():
# warning-ignore:return_value_discarded
	self.connect("matchmaking_connected", self, "server_hello")
# warning-ignore:return_value_discarded
	self.connect("matchmaking_received_message", self, "parse_signaling")

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
	send_message("LEAVE:" + str(id))

func server_hello():
	send_message("SERVER:"+JSON.print({"hidden": serversettings.hidden, "name": serversettings.name}))

func refresh_servers():
	send_message("LIST")

func send_candidate(id: int, cand: String):
# warning-ignore:return_value_discarded
	send_message("CONNECTION:"+str(id)+":CANDIDATE:"+cand)

func send_session(id: int, sess: String):
# warning-ignore:return_value_discarded
	send_message("CONNECTION:"+str(id)+":SESSION:"+sess)

func send_game_progress(inprogress: bool):
	send_message("GAMEINPROGRESS:"+("YES" if inprogress else "NO"))
