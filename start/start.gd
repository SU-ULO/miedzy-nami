extends Node

enum {NONE, SERVER, CLIENT}

var network_side := NONE

onready var menu := $MainMenu
var matchmaking = null
var network = null

func _ready():
# warning-ignore:return_value_discarded
	menu.connect("request_start_client", self, "start_client")
# warning-ignore:return_value_discarded
	menu.connect("request_start_server", self, "start_server")
# warning-ignore:return_value_discarded
	menu.connect("request_end", self, "leave_room")

func leave_matchmaking():
	leave_room()
	if matchmaking:
		matchmaking.queue_free()
	matchmaking=null
	network_side = NONE
	menu.open_main()

func leave_room():
	if network:
		network.queue_free()
	network = null
	if network_side==CLIENT:
		menu.open_roomlist()
	elif network_side==SERVER:
		leave_matchmaking()
		menu.open_create_room()
	else:
		menu.open_main()
	network_side = NONE

func start_server(options):
	if network_side != NONE:
		leave_room()
	matchmaking = Server_Matchmaking.new(menu.usersettings["signaling_url"], options)
	network = ServerNetworkManager.new()
	matchmaking.connect("matchmaking_disconnected", self, "leave_matchmaking")
	matchmaking.connect("join_room", network, "create_world")
	matchmaking.connect("key_changed", network, "display_key")
	network.connect("joined_room", menu, "close_everything")
	add_child(matchmaking)
	add_child(network)
	matchmaking.start()

func start_client():
	if network_side != NONE:
		leave_room()
	matchmaking = Client_Matchmaking.new(menu.usersettings["signaling_url"], menu.usersettings)
	matchmaking.connect("matchmaking_disconnected", self, "leave_matchmaking")
	matchmaking.connect("room_list_updated", menu, "update_servers")
	matchmaking.connect("matchmaking_hello", menu, "open_roomlist")
	add_child(matchmaking)
	matchmaking.start()
