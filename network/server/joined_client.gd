extends Game_Connection

class_name JoinedClient

var joined := false

signal player_character_sync(data)

func _init(conf: Dictionary).(conf):
	pass

func get_event_task_data(tasks) -> Dictionary:
	return {"add_tasks": tasks}

func handle_updates(input):
	if !(input is Array): return
	if input[0]==0:
		var data = input[1]
		emit_signal("player_character_sync", data)

func handle_events(input):
	#this entire thing will have to be changed to signal handled by ServerNetworkManager
	if input is Dictionary:
		if input.has("update_tasks"):
			var Task = load("res://scripts/tasks/Task.cs")
			var tasks = Task.GetAllTasks()
			if input.has("state") and input["state"] is Dictionary:
				for i in input["state"]:
					if tasks[i].IsDone() == false:
						tasks[i].state = input["state"][i]
					tasks[i].local = true
			if input.has("started") and input["started"] is Dictionary:
				for i in input["started"]:
					tasks[i].started = input["started"][i]
					tasks[i].local = true

func send_initial_sync(data: Dictionary, id: int):
	send_events([0, id, data])

func send_spawning_player_sync(data: Dictionary, id: int):
	send_events([1, id, data])

func send_player_removal_notification(id: int):
	send_events([2, id])

func send_player_character_sync_data(data):
	send_updates([0, data])
