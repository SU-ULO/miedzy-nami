extends Game_Connection

class_name JoinedServer

signal initial_sync(id, players_data)
signal remote_player_joined(id, data)
signal remote_player_left(id)
signal players_sync(players_data)

func _init(conf: Dictionary).(conf):
	pass

func _ready():
	peer.create_offer()

func leave():
	.leave()

func spawn_player():
	pass

func handle_events(input):
	if input is Array:
		if input.size()==3:
			if input[0] is int and input[1] is int and input[2] is Dictionary:
				if input[0]==0:
					#initial players spawn
					emit_signal("initial_sync", input[1], input[2])
				elif input[0]==1:
					#remote player joined
					emit_signal("remote_player_joined", input[1], input[2])
		elif input.size()==2:
			if input[0] is int and input[1] is int:
				if input[0]==2:
					emit_signal("remote_player_left", input[1])
#tasks need to be added to event handling as signal handled by ClientNetworkManager

func handle_updates(input):
	if input is Dictionary:
		emit_signal("players_sync", input)
			

func send_player_update(mov, pos):
	send_updates({"mov": mov, "pos": pos})

