extends Node

class_name Client

var wsc = WebSocketClient.new()


var joined_server = null

var menu = preload('res://client/menu/menu.tscn').instance()
func _ready():
	menu.name='menu'
	wsc.connect("connection_closed", self, "_closed_ws")
	wsc.connect("connection_error", self, "_connection_error")
	wsc.connect("connection_established", self, "_connected_ws")
	wsc.connect("data_received", self, "_data_ws")
	wsc.connect("server_close_request", self, "_closed_request_ws")
	
	
	menu.connect("start", self, 'start')
	menu.connect("end", self, 'end')
	menu.connect("refresh_servers", self, 'refresh_servers')
	menu.connect("join_server", self, 'request_join_server')
	add_child(menu)

func parse_signaling(msg:  String):
	if msg.begins_with("HELLO"):
		if msg.begins_with("HELLO:"):
			var arr = msg.split(":", false, 1)
			if arr.size()==2:
				var pars=JSON.parse(arr[1])
				if pars.error==OK && pars.result is Dictionary:
					var conf=pars.result
		else:
			menu.open_join()
			refresh_servers()
			return
		wsc.disconnect_from_host(4000, "WRONG_HELLO")
	elif msg.begins_with("LIST:"):
		var arr = msg.split(":", false, 1)
		if arr.size()<2: return
		var list = JSON.parse(arr[1])
		if list.error!=OK: return
		if list.result is Array:
			menu.update_servers(list.result)
	elif msg=="LEAVE":
		leave_server()
	elif msg.begins_with("JOIN:"):
		var arr = msg.split(":", false, 1)
		if arr.size()<2: return
		var pars = JSON.parse(arr[1])
		if pars.error!=OK: return
		if pars.result is Dictionary:
			var conf: Dictionary = pars.result
			if !conf.has('key') || !conf.has('webrtc'):
				wsc.get_peer(1).put_packet("LEAVE".to_utf8())
				return
			joined_server = JoinedServer.new(conf)
			joined_server.connect("fail", self, "leave_server")
			joined_server.connect("send_session", self, "send_session")
			joined_server.connect("send_candidate", self, "send_candidate")
			joined_server.connect("success", self, "_on_connected_server")
			joined_server.connect("join", self, "join_server")
			add_child(joined_server)
	elif msg.begins_with("CONNECTION:"):
		if !joined_server:
			leave_server()
			return
		var arr = msg.split(":", false, 2)
		if arr.size()<3:
			leave_server()
			return
		if arr[1]=="SESSION":
			joined_server.set_session(arr[2])
		elif arr[1]=="CANDIDATE":
			joined_server.set_candidate(arr[2])
		else:
			leave_server()
			return

func send_candidate(cand: String):
	wsc.get_peer(1).put_packet(("CONNECTION:CANDIDATE:"+cand).to_utf8())

func send_session(sess: String):
	wsc.get_peer(1).put_packet(("CONNECTION:SESSION:"+sess).to_utf8())

func _on_connected_server():
	print("connected")

func join_server():
	print("joined")

func request_join_server(key: String):
	wsc.get_peer(1).put_packet(("JOIN:"+key).to_utf8())

func leave_server():
	if joined_server:
		joined_server.leave()
		joined_server.queue_free()
		menu.open_join()
	joined_server=null

func start():
	if wsc.connect_to_url(menu.usersettings.signaling_url) != OK:
		print("Unable to connect to matchmaking server")
		end()
		return
	menu.open_logging_in()

func end():
	leave_server()
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.disconnect_from_host()
	menu.end()

func refresh_servers():
	wsc.get_peer(1).put_packet("LIST".to_utf8())

func _closed_request_ws(code: int, reason: String):
	print("closed with ", code, " ", reason)
	end()

func _closed_ws(_was_clean = false):
	print("Disconnected from matchmaking server")
	end()

func _connection_error():
	print("Error connecting to matchmaking")
	end()

func _connected_ws(_proto = ""):
	print("Connected to matchmaking server")
	wsc.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	if menu.usersettings.username.length()>0:
		wsc.get_peer(1).put_packet(("CLIENT:"+JSON.print({"username": menu.usersettings.username})).to_utf8())
	else:
		end()

func _data_ws():
	parse_signaling(wsc.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.poll()
