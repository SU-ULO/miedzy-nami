extends Game_Connection

class_name JoinedServer

signal initial_sync(id, players_data)
signal remote_player_joined(id, data)
signal remote_player_left(id)
signal players_sync(players_data)
signal kill(dead, pos, spawnbody, killer)
signal state_sync(state, params, opt)
signal sabotage(type)
signal end_sabotage(type)
signal cameras_enable()
signal gui_sync(gui_name, gui_data)
signal game_settings(settings)
signal colors_sync(taken, players)
signal look(id, look)
signal invisible(id, val)
signal vote(voter, voted)
signal vc_offer(offer, id)
signal vc_answer(answer, id)
signal vc_candidate(candidate, id)
signal vc_speaking(speaking, id)

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
		emit_signal("kill", input[1], input[2], input[3], input[4])
	elif input[0]==4:
		emit_signal("state_sync", input[1], input[2], input[3])
	elif input[0]==5:
		emit_signal("sabotage", input[1])
	elif input[0]==6:
		emit_signal("end_sabotage", input[1])
	elif input[0]==7:
		emit_signal("cameras_enable", input[1])
	elif input[0]==8:
		emit_signal("game_settings", input[1])
	elif input[0]==9:
		emit_signal("colors_sync", input[1], input[2])
	elif input[0]==10:
		emit_signal("gui_sync", input[1], input[2])
	elif input[0]==11:
		emit_signal("look", input[1], input[2])
	elif input[0]==12:
		emit_signal("invisible", input[1], input[2])
	elif input[0]==13:
		emit_signal("vote", input[1], input[2])
	elif input[0]==14:
		emit_signal("vc_offer", input[1], input[2])
	elif input[0]==15:
		emit_signal("vc_answer", input[1], input[2])
	elif input[0]==16:
		emit_signal("vc_candidate", input[1], input[2])
	elif input[0]==17:
		emit_signal("vc_speaking", input[1], input[2])

func handle_updates(input):
	if !(input is Array): return
	if input[0]==0:
		emit_signal("players_sync", input[1])

func send_meeting_request(dead: int):
	send_events([0, dead])

func send_kill_request(dead: int):
	send_events([1, dead])

func send_player_character_sync(data):
	send_updates([0, data])

func send_sabotage_request(type: int, own_id: int):
	send_events([2, type, own_id])

func send_end_sabotage_request(type: int):
	send_events([3, type])

func send_cameras_enable_request(on_off: bool):
	send_events([4, on_off])

func send_tasks_done(finished: int):
	send_events([5, finished])

func send_color_change(color: int):
	send_events([6, color])

func send_gui_sync_request(gui_name: String, gui_data):
	send_events([7, gui_name, gui_data])

func send_look_update(look: Dictionary):
	send_events([8, look])

func send_set_invisible(id, val: bool):
	send_events([9, id, val])

func send_vote(id):
	send_events([10, id])

func send_vc_offer(offer, id: int):
	send_events([11, offer, id])

func send_vc_answer(answer, id: int):
	send_events([12, answer, id])

func send_vc_candidate(candidate, id: int):
	send_events([13, candidate, id])

func send_vc_speaking(speaking: bool):
	send_events(([14, speaking]))
