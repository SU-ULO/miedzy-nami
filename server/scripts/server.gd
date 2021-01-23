extends Node

var wsc = WebSocketClient.new()

var signalling_url: String = 'wss://gaming.rakbook.pl/miedzy-nami/signalling'


func parse_args():
	var args = Array(OS.get_cmdline_args())
	var idx=args.find('--signalling')
	if(idx>-1&&args.size()>idx):
		signalling_url=args[idx+1]

func _ready():
	print("Running as server")
	parse_args()
	
	wsc.connect("connection_closed", self, "_closed_ws")
	wsc.connect("connection_error", self, "_closed_ws")
	wsc.connect("connection_established", self, "_connected_ws")
	wsc.connect("data_received", self, "_data_ws")
	
	var err = wsc.connect_to_url(signalling_url)
	if err != OK:
		print("Unable to connect to matchmaking server at "+signalling_url)
		get_tree().quit()
		return

func _closed_ws(_was_clean = false):
	print("Disconnected from matchmaking server at "+signalling_url)
	get_tree().quit()

func _connected_ws(_proto = ""):
	print("Connected to matchmaking server at "+signalling_url)
	wsc.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	wsc.get_peer(1).put_packet("S".to_utf8())

func _data_ws():
	print(wsc.get_peer(1).get_packet().get_string_from_utf8())

func _process(_delta):
	if wsc.get_connection_status()!=WebSocketClient.CONNECTION_DISCONNECTED:
		wsc.poll()
