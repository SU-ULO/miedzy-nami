extends Game_Connection

class_name JoinedClient

var joined := false

signal player_movement_update(mov, pos)

func _init(conf: Dictionary).(conf):
	pass

func get_event_task_data(tasks) -> Dictionary:
	return {"add_tasks": tasks}

func handle_updates(input):
	if input is Dictionary:
		if input.has("mov") and input["mov"] is Vector2 and input.has("pos") and input["pos"] is Vector2:
			emit_signal("player_movement_update", input["mov"], input["pos"])

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
