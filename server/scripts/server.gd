extends Node

var wsc = WebSocketClient.new()

var signalling_url: String = 'ws://localhost:8080'#'wss://gaming.rakbook.pl/miedzy-nami/signalling'
var key: String =""

var joined_clients: Dictionary = {}

func parse_args():
	var args = Array(OS.get_cmdline_args())
	var idx=args.find('--matchmaking')
	if(idx>-1&&args.size()>idx):
		signalling_url=args[idx+1]

func parse_signalling(msg:  String):
	if key=="":
		if msg.begins_with("KEY:"):
			var res = msg.split(":", false, 1)
			if res.size()<2: return
			key = res[1]
			print("KEY: "+key)
			return
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
			if joined_clients.has(conf.id) or !conf.has('webrtc'):
				leave(conf.id)
				return
			var client = JoinedClient.new(conf)
			client.connect("fail", self, "leave", [conf.id])
			client.connect("send_session", self, "send_session", [conf.id])
			client.connect("send_candidate", self, "send_candidate", [conf.id])
			client.connect("success", self, "join", [conf.id])
			joined_clients[conf.id]=client;
			add_child(client)
	elif msg.begins_with("CONNECTION:"):
		var arr = msg.split(":", false, 3)
		if arr.size()<4:
			return
		var id = int(arr[1])
		if !joined_clients.has(id):
			leave(id)
			return
		if arr[2]=="SESSION":
			joined_clients[id].set_session(arr[3])
		elif arr[2]=="CANDIDATE":
			joined_clients[id].set_candidate(arr[3])
		else:
			leave(id)
			return

func leave(id: int):
	if joined_clients.has(id):
		joined_clients[id].queue_free()
# warning-ignore:return_value_discarded
		joined_clients.erase(id)
	wsc.get_peer(1).put_packet(("LEAVE:"+str(id)).to_utf8())

func join(id: int):
	print("success")

func send_candidate(cand: String, id: int):
	wsc.get_peer(1).put_packet(("CONNECTION:"+str(id)+":CANDIDATE:"+cand).to_utf8())

func send_session(sess: String, id: int):
	wsc.get_peer(1).put_packet(("CONNECTION:"+str(id)+":SESSION:"+sess).to_utf8())

func _ready():
	print("Running as server")
	parse_args()
	
	wsc.connect("connection_closed", self, "_closed_ws")
	wsc.connect("connection_error", self, "_closed_ws")
	wsc.connect("connection_established", self, "_connected_ws")
	wsc.connect("data_received", self, "_data_ws")
	wsc.connect("server_close_request", self, "_closed_request_ws")
	
	var err = wsc.connect_to_url(signalling_url)
	if err != OK:
		print("Unable to connect to matchmaking server at "+signalling_url)
		get_tree().quit()
		return

func _closed_ws(_was_clean = false):
	print("Disconnected from matchmaking server at "+signalling_url)
	get_tree().quit()

func _closed_request_ws(code: int, reason: String):
	print("closed with ", code, " ", reason)

func _connected_ws(_proto = ""):
	print("Connected to matchmaking server at "+signalling_url)
	wsc.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	wsc.get_peer(1).put_packet("SERVER".to_utf8())

func _data_ws():
	parse_signalling(wsc.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.poll()