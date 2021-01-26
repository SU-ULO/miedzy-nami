extends Node

class_name Client

var wsc = WebSocketClient.new()


var joined_server = null

var menu = preload('res://client/menu/menu.tscn').instance()
func _ready():
	menu.name='menu'
	wsc.connect("connection_closed", self, "_closed_ws")
	wsc.connect("connection_error", self, "_closed_ws")
	wsc.connect("connection_established", self, "_connected_ws")
	wsc.connect("data_received", self, "_data_ws")
	wsc.connect("server_close_request", self, "_closed_request_ws")
	
	
	menu.connect("start", self, 'start')
	menu.connect("end", self, 'end')
	menu.connect("refresh_servers", self, 'refresh_servers')
	menu.connect("join_server", self, 'request_join_server')
	add_child(menu)

func parse_signalling(msg:  String):
	if msg.begins_with("LIST:"):
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
				return;
			joined_server = JoinedServer.new(conf)

func request_join_server(key: String):
	wsc.get_peer(1).put_packet(("JOIN:"+key).to_utf8())

func leave_server():
	if joined_server:
		joined_server.leave()
	joined_server=null
	menu.open_join()

func start():
	var err = wsc.connect_to_url(menu.usersettings.signalling_url)
	if err != OK:
		print("Unable to connect to matchmaking server at "+menu.usersettings.signalling_url)
		menu.end()
		return

func end():
	wsc.get_peer(1).close()

func refresh_servers():
	wsc.get_peer(1).put_packet("LIST".to_utf8())

func _closed_request_ws(code: int, reason: String):
	print("closed with ", code, " ", reason)

func _closed_ws(_was_clean = false):
	print("Disconnected from matchmaking server at "+menu.usersettings.signalling_url)
	menu.end()

func _connected_ws(_proto = ""):
	print("Connected to matchmaking server at "+menu.usersettings.signalling_url)
	wsc.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	wsc.get_peer(1).put_packet("CLIENT".to_utf8())
	refresh_servers()

func _data_ws():
	parse_signalling(wsc.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.poll()
