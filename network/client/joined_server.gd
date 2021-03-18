extends Game_Connection

class_name JoinedServer

signal initial_sync(id, players_data)
signal remote_player_joined(id, data)
signal remote_player_left(id)
signal players_sync(players_data)
signal meeting_start(caller, dead)

func _init(conf: Dictionary).(conf):
	pass

func _ready():
	peer.create_offer()

func leave():
	.leave()

func spawn_player():
	pass

func handle_events(input):
	if !(input is Array): return
	if input[0]==0:
		emit_signal("initial_sync", input[1], input[2])
	elif input[0]==1:
		emit_signal("remote_player_joined", input[1], input[2])
	elif input[0]==2:
		emit_signal("remote_player_left", input[1])
	elif input[0]==3:
		emit_signal("meeting_start", input[1], input[2])
#tasks need to be added to event handling as signal handled by ClientNetworkManager

func handle_updates(input):
	if !(input is Array): return
	if input[0]==0:
		emit_signal("players_sync", input[1])
	

func send_meeting_request(dead: int):
	send_events([0, dead])

func send_player_character_sync(data):
	send_updates([0, data])

