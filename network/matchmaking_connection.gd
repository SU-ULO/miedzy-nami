extends Node

class_name Matchmaking_Connection

var wsc := WebSocketClient.new()
var world := preload('res://scenes/school.tscn').instance()

var matchmaking_url: String = 'wss://gaming.rakbook.pl/miedzy-nami/signaling'

signal matchmaking_connected()
signal matchmaking_disconnected()
signal matchmaking_received_message(message)

func _init(url):
	matchmaking_url = url

func _ready():
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

func send_message(msg: String):
# warning-ignore:return_value_discarded
	wsc.get_peer(1).put_packet(msg.to_utf8())

func end():
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.disconnect_from_host()
	emit_signal("matchmaking_disconnected")

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
	emit_signal("matchmaking_connected")

func _data_ws():
	emit_signal("matchmaking_received_message", wsc.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.poll()

func start():
	if wsc.connect_to_url(matchmaking_url) != OK:
		print("Unable to connect to matchmaking server")
		end()
		return
