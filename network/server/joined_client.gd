extends Game_Connection

class_name JoinedClient

var joined := false

signal player_character_sync(data)
signal meeting_requested(dead)
signal kill_requested(dead)
signal sabotage_requested(type, player_id)
signal end_sabotage_requested(type)
signal cameras_enable_requested()
signal tasks_done(finished)
signal gui_sync_requested(gui_name, gui_data)
signal color_update(color)
signal look_update(look)
signal set_invisible(id, val)
signal vote(id)

func _init(conf: Dictionary).(conf):
	pass

func handle_updates(input):
	if !(input is Array): return
	if input[0]==0:
		var data = input[1]
		emit_signal("player_character_sync", data)

func handle_events(input):
	if !(input is Array): return
	if input[0]==0:
		emit_signal("meeting_requested", input[1])
	elif input[0]==1:
		emit_signal("kill_requested", input[1])
	elif input[0]==2:
		emit_signal("sabotage_requested", input[1], input[2])
	elif input[0]==3:
		emit_signal("end_sabotage_requested", input[1])
	elif input[0]==4:
		emit_signal("cameras_enable_requested", input[1])
	elif input[0]==5:
		emit_signal("tasks_done", input[1])
	elif input[0]==6:
		emit_signal("color_update", input[1])
	elif input[0]==7:
		emit_signal("gui_sync_requested", input[1], input[2])
	elif input[0]==8:
		emit_signal("look_update", input[1])
	elif input[0]==9:
		emit_signal("set_invisible", input[1], input[2])
	elif input[0]==10:
		emit_signal("vote", input[1])

func send_player_character_sync_data(data):
	send_updates([0, data])

func send_initial_sync(data: Dictionary, id: int):
	send_events([0, id, data])

func send_spawning_player_sync(data: Dictionary, id: int):
	send_events([1, id, data])

func send_player_removal_notification(id: int):
	send_events([2, id])

func send_kill(dead: int, pos: Vector2, generatebody: bool = true, killer: int = -1):
	send_events([3, dead, pos, generatebody, killer])

func send_gamestate(state, params, opt=null):
	send_events([4, state, params, opt])
	
func send_sabotage_start(type):
	send_events([5, type])

func send_end_sabotage(type):
	send_events([6, type])

func send_cameras_enable(on_off: bool):
	send_events([7, on_off])

func send_game_settings(settings):
	send_events([8, settings])

func send_colors(taken: int, players: Dictionary):
	send_events([9, taken, players])

func send_gui_sync(gui_name: String, gui_data):
	send_events([10, gui_name, gui_data])

func send_look(id: int, look: Dictionary):
	send_events([11, id, look])

func send_set_invisible(id, val: bool):
	send_events([12, id, val])

func send_vote(voter, voted):
	send_events([13, voter, voted])

func send_tasks_done(done: int, all: int):
	send_events([14, done, all])
