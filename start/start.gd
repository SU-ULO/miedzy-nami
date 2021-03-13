extends Node

enum {NONE, SERVER, CLIENT}

var network_side := NONE

onready var menu := $MainMenu
var matchmaking = null
var network = null

func _ready():
# warning-ignore:return_value_discarded
	menu.connect("request_start_server", self, "start_server")
# warning-ignore:return_value_discarded
	menu.connect("request_end", self, "leave_room")

func leave_matchmaking():
	network_side = NONE
	menu.open_main()

func leave_room():
	if network_side==CLIENT:
		menu.open_roomlist()
	elif network_side==SERVER:
		menu.open_create_room()
	else:
		menu.open_main()
	network_side = NONE

func start_server(options):
	if network_side != NONE:
		leave_room()
	print(options)
