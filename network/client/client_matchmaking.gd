extends Matchmaking_Connection

class_name Client_Matchmaking

signal matchmaking_hello()
signal room_list_updated(list)
signal received_session(sess)
signal received_candidate(cand)

var clientsettings

func _init(url, settings).(url):
	clientsettings = settings

func _ready():
# warning-ignore:return_value_discarded
	self.connect("matchmaking_connected", self, "client_hello")
# warning-ignore:return_value_discarded
	self.connect("matchmaking_received_message", self, "parse_matchmaking")

func parse_matchmaking(msg:  String):
	if msg.begins_with("HELLO"):
		refresh_servers()
		emit_signal("matchmaking_hello")
		return
	elif msg.begins_with("LIST:"):
		var arr = msg.split(":", false, 1)
		if arr.size()<2: return
		var list = JSON.parse(arr[1])
		if list.error!=OK: return
		if list.result is Array:
			emit_signal("room_list_updated", list.result)
	elif msg=="LEAVE":
		emit_signal("leave_room")
	elif msg.begins_with("JOIN:"):
		var arr = msg.split(":", false, 1)
		if arr.size()<2: return
		var pars = JSON.parse(arr[1])
		if pars.error!=OK: return
		if pars.result is Dictionary:
			var conf: Dictionary = pars.result
			if !conf.has('key') || !conf.has('webrtc'):
# warning-ignore:return_value_discarded
				wsc.get_peer(1).put_packet("LEAVE".to_utf8())
				return
			emit_signal("join_room", conf)
	elif msg.begins_with("CONNECTION:"):
		var arr = msg.split(":", false, 2)
		if arr.size()<3:
			return
		if arr[1]=="SESSION":
			emit_signal("received_session", arr[2])
		elif arr[1]=="CANDIDATE":
			emit_signal("received_candidate", arr[2])
		else:
			return

func client_hello():
	send_message("CLIENT:"+JSON.print({"username": clientsettings.username}))

func refresh_servers():
	send_message("LIST")

func send_candidate(cand: String):
	send_message("CONNECTION:CANDIDATE:"+cand)

func send_session(sess: String):
	send_message("CONNECTION:SESSION:"+sess)
