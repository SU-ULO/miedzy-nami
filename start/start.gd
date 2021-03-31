extends Node

class_name Start

enum {NONE, SERVER, CLIENT}

var network_side := NONE

onready var menu := $MainMenu
var matchmaking = null
var network = null

func _ready():
	randomize()
# warning-ignore:return_value_discarded
	menu.connect("request_start_client", self, "start_client")
# warning-ignore:return_value_discarded
	menu.connect("request_join_server", self, "join_server")
# warning-ignore:return_value_discarded
	menu.connect("request_start_server", self, "start_server")
# warning-ignore:return_value_discarded
	menu.connect("request_end", self, "leave_room")

func leave_matchmaking():
	if matchmaking:
		matchmaking.queue_free()
	matchmaking=null
	network_side = NONE
	menu.open_main()
	leave_room()

func leave_room():
	if network:
		network.queue_free()
	network = null
	if network_side==CLIENT:
		menu.open_roomlist()
	elif network_side==SERVER:
		if matchmaking: leave_matchmaking()
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
	matchmaking.connect("client_connecting", network, "create_client")
	matchmaking.connect("received_session", network, "set_session")
	matchmaking.connect("received_candidate", network, "set_candidate")
	matchmaking.connect("key_changed", network, "display_key")
	network.connect("joined_room", menu, "close_everything")
	network.connect("send_session", matchmaking, "send_session")
	network.connect("send_candidate", matchmaking, "send_candidate")
	network.connect("gameinprogresschange", matchmaking, "send_game_progress")
	network.connect("kick", matchmaking, "kick")
	add_child(matchmaking)
	add_child(network)
	matchmaking.start()
	network_side = SERVER

func start_client():
	if network_side != NONE:
		leave_room()
	matchmaking = Client_Matchmaking.new(menu.usersettings["signaling_url"], menu.usersettings)
	matchmaking.connect("matchmaking_disconnected", self, "leave_matchmaking")
	matchmaking.connect("leave_room", self, "leave_room")
	matchmaking.connect("room_list_updated", menu, "update_servers")
	matchmaking.connect("matchmaking_hello", menu, "open_roomlist")
	matchmaking.connect("loading_label", menu, "joining_label")
	add_child(matchmaking)
	matchmaking.start()
	network_side = CLIENT

func join_server(key):
	if network_side != CLIENT or !matchmaking:
		leave_matchmaking()
		return
	if !network or !(network is ClientNetworkManager):
		network = ClientNetworkManager.new()
		matchmaking.connect("join_room", network, "create_world")
		matchmaking.connect("received_session", network, "set_session")
		matchmaking.connect("received_candidate", network, "set_candidate")
		network.connect("send_session", matchmaking, "send_session")
		network.connect("send_candidate", matchmaking, "send_candidate")
		network.connect("joined_room", menu, "close_everything")
		add_child(network)
	matchmaking.join_server(key)
