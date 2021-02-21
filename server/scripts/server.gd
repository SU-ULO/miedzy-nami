extends Node

var wsc := WebSocketClient.new()
var world := preload('res://scenes/school.tscn').instance()

var signaling_url: String = 'wss://gaming.rakbook.pl/miedzy-nami/signaling'
var server_name: String = ""

var joined_clients: Dictionary = {}

func is_username_taken(requested_name: String)->bool:
	for c in joined_clients.values():
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

func parse_args():
	var args = Array(OS.get_cmdline_args())
	var idx=args.find('--matchmaking')
	if(idx>-1&&args.size()>idx):
		signaling_url=args[idx+1]
	idx=args.find('--name')
	if(idx>-1&&args.size()>idx):
		server_name=args[idx+1]

func parse_signaling(msg:  String):
	if msg.begins_with("HELLO:"):
		var arr = msg.split(":", false, 1)
		if arr.size()==2:
			var pars=JSON.parse(arr[1])
			if pars.error==OK && pars.result is Dictionary:
				var conf=pars.result
				if conf.has("key"):
					print("KEY: "+conf.key)
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
			if joined_clients.has(conf.id) or !conf.has('webrtc') or !conf.has('username'):
				leave(conf.id)
				return
			conf.username=get_non_taken_username(conf.username)
			var client := JoinedClient.new(conf)
# warning-ignore:return_value_discarded
			client.connect("fail", self, "leave", [conf.id])
# warning-ignore:return_value_discarded
			client.connect("send_session", self, "send_session", [conf.id])
# warning-ignore:return_value_discarded
			client.connect("send_candidate", self, "send_candidate", [conf.id])
# warning-ignore:return_value_discarded
			client.connect("success", self, "_on_connected_client", [conf.id])
# warning-ignore:return_value_discarded
			client.connect("join", self, "join", [conf.id])
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
	elif msg.begins_with("KEY:"):
		var arr = msg.split(":", false, 1)
		if arr.size()<2: return
		print("KEY: "+arr[1])
		return

func leave(id: int):
	if joined_clients.has(id):
		joined_clients[id].queue_free()
# warning-ignore:return_value_discarded
		joined_clients.erase(id)
	if wsc.get_connection_status()==WebSocketClient.CONNECTION_CONNECTED:
# warning-ignore:return_value_discarded
		wsc.get_peer(1).put_packet(("LEAVE:"+str(id)).to_utf8())

func _on_connected_client(id: int):
	print("connected "+String(id))

func join(id: int):
	print("joined "+String(id))

func send_candidate(cand: String, id: int):
# warning-ignore:return_value_discarded
	wsc.get_peer(1).put_packet(("CONNECTION:"+str(id)+":CANDIDATE:"+cand).to_utf8())

func send_session(sess: String, id: int):
# warning-ignore:return_value_discarded
	wsc.get_peer(1).put_packet(("CONNECTION:"+str(id)+":SESSION:"+sess).to_utf8())

func _ready():
	print("Running as server")
	parse_args()
	
# warning-ignore:return_value_discarded
	wsc.connect("connection_closed", self, "_closed_ws")
# warning-ignore:return_value_discarded
	wsc.connect("connection_error", self, "_connection_error")
# warning-ignore:return_value_discarded
	wsc.connect("connection_established", self, "_connected_ws")
# warning-ignore:return_value_discarded
	wsc.connect("data_received", self, "_data_ws")
# warning-ignore:return_value_discarded
	wsc.connect("server_close_request", self, "_closed_request_ws")
	
	var err = wsc.connect_to_url(signaling_url)
	if err != OK:
		print("Can't connect to matchmaking")
		get_tree().quit()
		return
	add_child(world)

func _closed_ws(_was_clean = false):
	print("Disconnected from matchmaking")
	get_tree().quit()

func _connection_error():
	print("Error connecting to matchmaking")
	get_tree().quit()

func _closed_request_ws(code: int, reason: String):
	print("closed with ", code, " ", reason)

func _connected_ws(_proto = ""):
	print("Connected to matchmaking")
	wsc.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
# warning-ignore:return_value_discarded
	wsc.get_peer(1).put_packet("SERVER".to_utf8())

func _data_ws():
	parse_signaling(wsc.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.poll()
