extends Node

class_name Client

var wsc = WebSocketClient.new()

var remote_players: Dictionary = {}
var own_player

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
	add_child(menu)

func parse_signalling(msg:  String):
	if msg.find("L:")==0:
		var res = msg.split(":", false, 1)
		if res.size()<2: return
		var list = JSON.parse(res[1])
		if list.error!=OK: return
		if list.result is Array:
			menu.update_servers(list.result)

func start():
	var err = wsc.connect_to_url(menu.usersettings.signalling_url)
	if err != OK:
		print("Unable to connect to matchmaking server at "+menu.usersettings.signalling_url)
		menu.end()
		return

func end():
	wsc.get_peer(1).close()

func refresh_servers():
	wsc.get_peer(1).put_packet("L".to_utf8())

func _closed_request_ws(code: int, reason: String):
	print("closed with ", code, " ", reason)

func _closed_ws(_was_clean = false):
	print("Disconnected from matchmaking server at "+menu.usersettings.signalling_url)
	menu.end()

func _connected_ws(_proto = ""):
	print("Connected to matchmaking server at "+menu.usersettings.signalling_url)
	wsc.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	wsc.get_peer(1).put_packet("C".to_utf8())
	refresh_servers()

func _data_ws():
	parse_signalling(wsc.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.poll()
